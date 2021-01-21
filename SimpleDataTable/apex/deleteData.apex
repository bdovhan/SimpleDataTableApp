delete [SELECT Id FROM Contact WHERE RecordType.Name = 'Employee'];
Database.emptyRecycleBin([SELECT Id FROM Contact WHERE RecordType.Name = 'Employee' AND IsDeleted = True ALL ROWS]);