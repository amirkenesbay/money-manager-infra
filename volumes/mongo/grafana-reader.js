const password = process.env.MONGO_GRAFANA_PASSWORD;
const database = 'moneyManagerBot';
const user = 'grafanaReader';
const role = 'grafanaUsersRead';
const readable = ['finance_operation', 'money_manager_user'];

if (!password) {
  print('MONGO_GRAFANA_PASSWORD is empty, skipping the Grafana reader');
} else {
  const target = db.getSiblingDB(database);
  const privileges = readable.map((collection) => ({ resource: { db: database, collection }, actions: ['find'] }));
  if (target.getRole(role)) target.updateRole(role, { privileges, roles: [] });
  else target.createRole({ role, privileges, roles: [] });
  const grant = { pwd: password, roles: [{ role, db: database }] };
  if (target.getUser(user)) target.updateUser(user, grant);
  else target.createUser({ user, ...grant });
  print('Grafana reader is ready');
}
