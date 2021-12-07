import pyodbc
from datetime import datetime

#driver= '{ODBC Driver 17 for SQL Server}'
#cnxn =     pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1433;DATABASE='+databas    e+';UID='+username+';PWD='+ password)


class MsSql:
    def __init__(self, server, database, user, password):
        #driver= '{ODBC Driver 17 for SQL Server}'
        driver= '{SQL Server Native Client 11.0}'
        connstr = ("Driver={SQL Server Native Client 11.0};"
                                   "Server="+server+";"
                                   "Database="+database+";"
                                   "UID="+user+";"
                                   "PWD="+password+";"
                                   "Trusted_Connection=yes;")
        #print(connstr)                           
        self.database = database
        self.cnxn = pyodbc.connect(connstr)                           
        self.query = "-- {}\n\n-- Made in Python".format(datetime.now()
                                                         .strftime("%d/%m/%Y"))

    def firstquery(self):
        return self.query  

    def backup(self, backup_path, backup_name="backup.bak"):
        sql_cursor = self.cnxn.cursor()
        query = (
                 "EXEC master.dbo.BackupCopyDB "
                 "@db = '" + self.database + "', "
                 "@b_path = '" + backup_path.strip() + "\\', "
                 "@email = 'maruniak.a@kp.budova.ua'")
        self.cnxn.autocommit = True
        sql_cursor.execute(query)
        self.cnxn.commit()


