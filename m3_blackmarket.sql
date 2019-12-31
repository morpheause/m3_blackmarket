USE `essentialmode`;


CREATE TABLE `m3_blackmarket_stock` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`type` varchar(255) DEFAULT NULL,
	`name` varchar(255) DEFAULT NULL,
	`label` varchar(255) DEFAULT NULL,
	`count` int(11) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

CREATE TABLE `m3_blackmarket_orders` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`identifier` varchar(255) DEFAULT NULL,
	`name` varchar(255) DEFAULT NULL,
	`label` varchar(255) DEFAULT NULL,
	`time` int(11) DEFAULT NULL,

	PRIMARY KEY (`id`)
);