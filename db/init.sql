SET NAMES utf8;
USE `opencloset-avatar`;

CREATE TABLE `avatar` (
  `id`     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `md5sum` CHAR(32)      NOT NULL,
  `image`  BLOB          NOT NULL,
  `create_date` DATETIME DEFAULT NULL,
  `update_date` DATETIME DEFAULT NULL,

  PRIMARY KEY (`id`),
  UNIQUE  KEY (`md5sum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
