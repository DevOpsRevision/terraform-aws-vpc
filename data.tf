data "aws_availability_zones" "available"{
    state = "available"
}

# Below is just for testing how the output looks for name formation.
# output "azs_info" {
#   value = data.aws_availability_zones.available
# }


data "aws_vpc" "default" {
    default = true
}