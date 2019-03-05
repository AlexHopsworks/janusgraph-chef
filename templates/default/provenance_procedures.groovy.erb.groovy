def addOperation(operation_id, operation_name, timestamp) {
  return { g.V().has('operation','o_id',operation_id).fold().coalesce(unfold(),g.addV('operation').property('o_id',operation_id).property('o_name',operation_name).property('o_time', timestamp)).as('ex_operation') }
}
def addProject(project_id, project_name) {
  return { f -> f.coalesce(g.V().has('project','p_id',project_id),addV('project').property('p_name',project_name).property('p_id',project_id)).as('ex_project') }
}
def addDataset(dataset_id, dataset_name) {
  return { f -> f.coalesce(g.V().has('dataset','d_id',dataset_id),addV('dataset').property('d_name',dataset_name).property('d_id',dataset_id)).as('ex_dataset') }
}
def addFile(file_id, file_name) {
  return { f -> f.coalesce(g.V().has('file','i_id',file_id),addV('file').property('i_name',file_name).property('i_id',file_id)).as('ex_file') }
}
def time(time_date, time_hour) {
  return { f -> f.coalesce(g.V().has('time_date','date',time_date),addV('time_date').property('date',time_date)).as('ex_time_date').coalesce(__.inE("ofDay").where(outV().has('hour', time_hour)).outV(),addV('time_hour').property('hour',time_hour).as('ex_time_hour').addE('ofDay').to('ex_time_date').select('ex_time_hour')).as('ex_time_hour') }
}
def getVertex(type, property_name, property_value, alias) {
  return { f -> f.coalesce(g.V().has(type,property_name,property_value),addV(type).property(property_name,property_value)).as(alias) }
}
def edge(from, name, to) {
  return { f -> f.select(from).coalesce(__.outE(name).where(inV().as(to)),addE(name).to(to))}
}
def projectOp(operation_id, operation_name, project_id, project_name, user_id, time_hour, time_date, timestamp) {
  // chaining as reverse composition chaining (named chains of operations)
  def chain = addOperation(operation_id, operation_name, timestamp) >> addProject(project_id, project_name) >> getVertex('user', 'u_id', user_id, 'ex_user') >> time(time_date, time_hour) >> edge('ex_operation', 'performedOnP', 'ex_project') >> edge('ex_operation', 'performedBy', 'ex_user') >> edge('ex_operation', 'performedAt', 'ex_time_hour') >> edge('ex_time_hour', 'ofDay', 'ex_time_date')
  chain().iterate()
}
def datasetOp(operation_id, operation_name, project_id, dataset_id, dataset_name, user_id, time_hour, time_date, timestamp) {
  def chain = addOperation(operation_id, operation_name, timestamp) >> getVertex('project', 'p_id', project_id, 'ex_project') >> addDataset(dataset_id, dataset_name) >> addFile(dataset_id, '.') >> getVertex('user', 'u_id', user_id, 'ex_user') >> time(time_date, time_hour) >> edge('ex_operation', 'performedOnF', 'ex_file') >> edge('ex_operation', 'performedBy', 'ex_user') >> edge('ex_operation', 'performedAt', 'ex_time_hour') >> edge('ex_file', 'childOfD', 'ex_dataset') >> edge('ex_dataset', 'childOfP', 'ex_project') >> edge('ex_time_hour', 'ofDay', 'ex_time_date')
  chain().iterate()
}
def fileOp(operation_id, operation_name, dir_id, file_id, file_name, user_id, time_hour, time_date, timestamp) {
  def chain = addOperation(operation_id, operation_name, timestamp) >> getVertex('file', 'i_id', dir_id, 'ex_parent') >> addFile(file_id, file_name) >> getVertex('user', 'i_id', user_id, 'ex_user') >> time(time_date, time_hour) >> edge('ex_operation', 'performedOnF', 'ex_file') >> edge('ex_operation', 'performedBy', 'ex_user') >> edge('ex_operation', 'performedAt', 'ex_time_hour') >> edge('ex_file', 'childOfF', 'ex_parent') >> edge('ex_time_hour', 'ofDay', 'ex_time_date')
  chain().iterate()
}
def batchOps(ArrayList<Map<String, String>> batch) {
  for (i = 0; i < batch.size(); i++) {
    def params = batch.getAt(i);
    if (params['i_id'] == params['p_id']) {
      projectOp(params['o_id'], params['o_name'], params['p_id'], params['i_name'], params['u_id'], params['t_hour'], params['t_date'], params['o_time']);
    } else if (params['i_id'] == params['d_id']) {
      datasetOp(params['o_id'], params['o_name'], params['p_id'], params['d_id'], params['i_name'], params['u_id'], params['t_hour'], params['t_date'], params['o_time']);
    } else {
      fileOp(params['o_id'], params['o_name'], params['dir_id'], params['i_id'], params['i_name'], params['u_id'], params['t_hour'], params['t_date'], params['o_time']);
    }
  } 
}
// an init script that returns a Map allows explicit setting of global bindings.
def globals = [:]

// defines a sample LifeCycleHook that prints some output to the Gremlin Server console.
// note that the name of the key in the 'global' map is unimportant.
globals << [hook : [
  onStartUp: { ctx ->
    ctx.logger.info('Provenance scripts - at startup of Gremlin Server.')
  },
  onShutDown: { ctx ->
    ctx.logger.info('Provenance scripts - at shutdown of Gremlin Server.')
  }
] as LifeCycleHook]

// define the default TraversalSource to bind queries to - this one will be named 'g'.
// ReferenceElementStrategy converts all graph elements (vertices/edges/vertex properties)
// to 'references' (i.e. just id and label without properties). this strategy was added
// in 3.4.0 to make all Gremlin Server results consistent across all protocols and
// serialization formats aligning it with TinkerPop recommended practices for writing
// Gremlin.
globals << [g : graph.traversal()]