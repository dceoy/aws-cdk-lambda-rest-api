terraform-aws-websocket-api
===========================

Terraform stacks for [the tutrial of Amazon API Gateway WebSocket API](https://docs.aws.amazon.com/apigateway/latest/developerguide/websocket-api-chat-app.html).

[![CI/CD](https://github.com/dceoy/terraform-aws-websocket-api/actions/workflows/ci.yml/badge.svg)](https://github.com/dceoy/terraform-aws-websocket-api/actions/workflows/ci.yml)

Installation
------------

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/terraform-aws-websocket-api.git
    $ cd terraform-aws-websocket-api
    ```

2.  Install [AWS CLI](https://aws.amazon.com/cli/) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Install [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/).

4.  Build the Docker images.

    ```sh
    $ ./docker_buildx_bake.sh
    ```

5.  Initialize Terraform working directories.

    ```sh
    $ terragrunt run-all init --terragrunt-working-dir='envs/dev/' -upgrade -reconfigure
    ```

6.  Generates a speculative execution plan. (Optional)

    ```sh
    $ terragrunt run-all plan --terragrunt-working-dir='envs/dev/'
    ```

7.  Creates or updates infrastructure.

    ```sh
    $ terragrunt run-all apply --terragrunt-working-dir='envs/dev/' --terragrunt-non-interactive
    ```

8.  Update the tokens in Parameter Store.

    ```sh
    $ aws ssm put-parameter --overwrite --name /toa/dev/twilio-auth-token --value <TWILIO_AUTH_TOKEN>
    ```

Cleanup
-------

```sh
$ terragrunt run-all destroy --terragrunt-working-dir='envs/dev/' --terragrunt-non-interactive
```
