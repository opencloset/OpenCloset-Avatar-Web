SET NAMES utf8;
USE `opencloset-avatar`;

CREATE TABLE `avatar` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `md5sum`      CHAR(32)     NOT NULL,
  `create_date` DATETIME     DEFAULT NULL,

  PRIMARY KEY (`id`),
  UNIQUE  KEY (`md5sum`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `avatar_image` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `avatar_id`   INT UNSIGNED NOT NULL,
  `image`       MEDIUMBLOB   NOT NULL,
  `rating`      INT          DEFAULT 0,
  `create_date` DATETIME     DEFAULT NULL,

  PRIMARY KEY (`id`),
  CONSTRAINT `fk_avatar_image1` FOREIGN KEY (`avatar_id`) REFERENCES `avatar` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
