variable "flow" {
  type    = string
  default = "soldatov"
}

variable "cloud_id" {
  type    = string
  default = "b1gskjehmm1acvp42s8n"
}
variable "folder_id" {
  type    = string
  default = "b1g0nt9tti7uhit2bnf5"
}

variable "test" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 3
    core_fraction = 20
  }
}