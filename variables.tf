variable "security_group_ids" {
    default = ["sg-0cb3d2b375fa6d466"]
}

variable "tags" {
    default = {
        Name = "roboshop-cart"
        Terraform = "true"
        Environment = "dev"
    }
}

variable "instance_type" {
    default = "t3.small"
}