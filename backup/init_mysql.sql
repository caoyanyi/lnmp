GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '%pwd%' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE User = '';
DELETE FROM mysql.user WHERE User = 'root' AND Host = 'localhost';
FLUSH PRIVILEGES;
