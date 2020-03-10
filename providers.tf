provider "aws" {}

provider "aws" {
  alias = "secondary"
}
provider "aws" {
  alias = "dns"
}