DROP DATABASE IF EXISTS `sample`;
CREATE DATABASE IF NOT EXISTS `sample` DEFAULT CHARACTER SET utf8mb4;

CREATE TABLE test (
  id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  secondaryId bigint(20) unsigned NOT NULL,
  PRIMARY KEY (id),
  KEY idxSecondaryId (secondaryId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

