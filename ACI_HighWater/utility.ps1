# Utility for PS

$querytext = "select * from micstats.taskruns"
$conn = New-Object System.Data.Odbc.OdbcConnection
$conn.ConnectionString = "DSN=MICStats"
$conn.open()
$cmd = New-Object System.Data.Odbc.OdbcCommand($querytext,$conn)
$ds = New-Object System.Data.DataSet
(New-Object System.Data.Odbc.OdbcDataAdapter($cmd)).fill($ds)

$conn.close()
$ds.tables[0]