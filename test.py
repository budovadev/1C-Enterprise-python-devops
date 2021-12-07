import yaml
from pprint import pprint
from dbclasses import MsSql



print('Старт')

#чтение настроек
with open('params.yaml') as f:
    settings = yaml.safe_load(f)


#backup sql
sql = MsSql(settings['sql_srvr'], settings['sql_db'], settings['sql_user'], settings['sql_pwd'])

#pprint(sql.firstquery)
#print("!!")
sql.backup(settings['bak_path'], settings['bak_name'])


#восстановление sql


pprint('Завершение')
