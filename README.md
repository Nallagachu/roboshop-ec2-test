# roboshop-ec2-test
A Terraform module designed for testing EC2 instance provisioning. Ideal for experimenting with configurations, validating changes, and developing reusable infrastructure patterns in a safe, isolated environment

# Roboshop EC2 Deployment Example

[](https://www.google.com/search?q=LICENSE)
[](https://releases.hashicorp.com/terraform/)
[](https://aws.amazon.com/)

This repository demonstrates a practical and efficient way to deploy an AWS EC2 instance for a **Roboshop test environment** by consuming a dedicated, reusable Terraform module. It highlights fundamental Infrastructure as Code (IaC) principles:

  * **Modularity (DRY):** Leveraging pre-built components.
  * **Centralized Control:** Maintaining standards through module usage.
  * **Secure State Management:** Storing Terraform state securely in Amazon S3.

## Table of Contents

1.  [Project Overview](https://www.google.com/search?q=%231-project-overview)
2.  [Key Features & Benefits](https://www.google.com/search?q=%232-key-features--benefits)
3.  [Module Architecture](https://www.google.com/search?q=%233-module-architecture)
4.  [Prerequisites](https://www.google.com/search?q=%234-prerequisites)
5.  [Getting Started](https://www.google.com/search?q=%235-getting-started)
      * [1. Clone This Repository](https://www.google.com/search?q=%231-clone-this-repository)
      * [2. Configure AWS S3 Backend](https://www.google.com/search?q=%232-configure-aws-s3-backend)
      * [3. Initialize Terraform](https://www.google.com/search?q=%233-initialize-terraform)
      * [4. Plan & Apply Your EC2 Instance](https://www.google.com/search?q=%234-plan--apply-your-ec2-instance)
6.  [Module Inputs Used](https://www.google.com/search?q=%236-module-inputs-used)
7.  [Outputs](https://www.google.com/search?q=%237-outputs)
8.  [Cleaning Up Resources](https://www.google.com/search?q=%238-cleaning-up-resources)
9.  [⚡ Important Note on State Locking ⚡](https://www.google.com/search?q=%239-important-note-on-state-locking)
10. [References](https://www.google.com/search?q=%2310-references)
11. [Contributing](https://www.google.com/search?q=%2311-contributing)
12. [License](https://www.google.com/search?q=%2312-license)
13. [Contact](https://www.google.com/search?q=%2313-contact)

## 1\. Project Overview

This project is specifically designed to provision an AWS EC2 instance that can serve as a component within a **Roboshop test environment**. Instead of defining the EC2 instance and its security group directly in this repository, we **consume an external Terraform module** that encapsulates this complex logic. This approach is highly beneficial as it demonstrates:

  * **Module Consumption in Practice:** How to effectively integrate and utilize a pre-existing Terraform module.
  * **Simplified Configuration:** Abstracting away the intricate details of resource creation into the module, allowing this repository to focus solely on the *parameters* needed for the Roboshop instance.
  * **Secure & Centralized State:** Reinforcing the best practice of storing Terraform's state file (`.tfstate`) in an **encrypted Amazon S3 bucket**, critical for secure collaboration and state integrity.

By adopting this modular strategy, we ensure consistent, maintainable, and securely managed deployments for our Roboshop testing infrastructure.

## 2\. Key Features & Benefits

  * **Consistent Roboshop Deployments:** Easily deploy new EC2 instances for Roboshop test components with consistent configurations.
  * **Reduced Complexity:** The underlying EC2 and security group logic is handled by the module, making this configuration lean and focused on application-specific parameters.
  * **Enforced Standards:** By consuming a module, this project inherently adheres to the standards and best practices defined within the `terraform-aws-instance` module (e.g., controlled instance types).
  * **Robust State Management:** Your `tfstate` file is stored remotely in an **encrypted S3 bucket**, ensuring:
      * **Data Security:** Sensitive state information is protected at rest.
      * **Durability:** Safeguarding your state from local failures.
      * **Version Control:** S3 bucket versioning provides a complete history for easy rollbacks.
  * **Clear Visibility:** Terraform outputs provide immediate access to the deployed EC2 instance's details (e.g., public IP), simplifying access and integration.
  * **Faster Iteration:** Quickly spin up and tear down test environments without recreating resource definitions.

## 3\. Module Architecture

This repository consumes the `terraform-aws-instance` module. For demonstration purposes, it's assumed the module is located locally, but in a production setup, it would typically be sourced from a remote registry or Git repository.

```
.
├── main.tf                     # Main configuration: calls the 'ec2-instance' module, defines AWS provider, and S3 remote backend
├── variables.tf                # Defines input variables that are passed to the module for the Roboshop instance
├── outputs.tf                  # Defines output values to display information about the deployed Roboshop instance
├── versions.tf                 # Specifies required Terraform and provider versions
├── .gitignore                  # Standard Git ignore file for Terraform artifacts (.terraform/, *.tfstate)
└── modules/                    # Directory containing locally referenced modules (if applicable)
    └── terraform-aws-instance/ # <-- Your cloned/referenced EC2 module repository
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── versions.tf
```

*(**Note:** In a typical production setup, the `modules/terraform-aws-instance/` directory might be replaced by a `source` reference in `main.tf` pointing to your module's remote Git repository or Terraform Registry entry, e.g., `source = "github.com/Nallagachu/terraform-aws-instance?ref=v1.0.0"`)*

## 4\. Prerequisites

To successfully deploy the Roboshop EC2 instance, ensure you have the following installed and configured:

  * **Terraform CLI:** Install [Terraform v1.x.x or higher](https://developer.hashicorp.com/terraform/downloads).
  * **AWS CLI:** Configure the [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) with credentials that possess the necessary permissions to:
      * Create and manage EC2 instances and Security Groups.
      * Create and manage S3 buckets (for remote state storage).
      * *(Highly Recommended)* Permissions to enable encryption on your S3 bucket.

## 5\. Getting Started

Follow these steps to quickly deploy an EC2 instance for your Roboshop test environment using this configuration.

### 1\. Clone This Repository

Begin by cloning this repository to your local machine:

```bash
git clone https://github.com/Nallagachu/roboshop-ec2-test.git
cd roboshop-ec2-test
```

### 2\. Configure AWS S3 Backend

Before executing any Terraform commands, you **must create a dedicated S3 bucket** in your AWS account. This bucket will serve as the secure remote backend for your Terraform state file.

  * **Choose a Globally Unique Bucket Name:** (e.g., `your-org-roboshop-tf-states-test-12345`).
  * **Enable Bucket Versioning:** This is critical for maintaining a historical record of your state and enabling rollbacks.

**Example AWS CLI commands to create and configure your S3 bucket:**

```bash
# 1. Create the S3 bucket (replace with your unique name and desired region)
aws s3 mb s3://your-unique-terraform-state-bucket-name --region us-east-1

# 2. Enable versioning on your bucket
aws s3api put-bucket-versioning \
    --bucket your-unique-terraform-state-bucket-name \
    --versioning-configuration Status=Enabled
```

Once your S3 bucket is ready, update the `bucket` attribute within the `backend "s3"` block in your **`main.tf` file** to match your bucket's name:

```terraform
# main.tf (in the root directory of this repository)
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket-name" # <--- ⚠️ UPDATE THIS LINE WITH YOUR S3 BUCKET NAME!
    key            = "roboshop-ec2-test/terraform.tfstate"      # Path within the bucket for this specific project
    region         = "us-east-1"                                # Ensure this matches your bucket's region
    encrypt        = true                                       # Ensure state file is encrypted at rest
  }
}
```

### 3\. Initialize Terraform

From the **root directory** of this repository, run `terraform init`. This command performs essential setup, including downloading the required AWS provider, pulling in the referenced `terraform-aws-instance` module, and configuring the S3 remote backend.

```bash
terraform init
```

### 4\. Plan & Apply Your EC2 Instance

With initialization complete, you can now preview and apply your infrastructure changes.

  * **Review the execution plan:** Always run `terraform plan` first. This command shows you exactly what resources Terraform proposes to create, modify, or destroy based on your configuration and current state.

    ```bash
    terraform plan
    ```

    Carefully examine the output. You should see a plan indicating the creation of an `aws_instance` and an `aws_security_group` (these resources are defined within the `terraform-aws-instance` module you are consuming).

  * **Apply the configuration:** If the plan looks correct, proceed to apply the configuration. Terraform will then provision these resources in your AWS account.

    ```bash
    terraform apply --auto-approve
    ```

    *(**Note:** The `--auto-approve` flag automatically confirms the plan. For production or critical deployments, it's highly recommended to omit this flag and manually type `yes` after a thorough review of the plan.)*

Upon successful application, Terraform will display the output values, such as your new EC2 instance's ID and public IP address.

## 6\. Module Inputs Used

This `roboshop-ec2-test` configuration calls the `terraform-aws-instance` module and passes the following input variables to customize the EC2 instance creation for the Roboshop environment. These variables are defined in the `variables.tf` file within this repository.

| Name                  | Description                                                                     | Type           | Default                    |
| :-------------------- | :------------------------------------------------------------------------------ | :------------- | :------------------------- |
| `instance_name`       | The name tag to apply to the EC2 instance for the Roboshop component.           | `string`       | `"roboshop-test-server"`   |
| `ami_id`              | The AMI ID for the EC2 instance (e.g., a suitable Amazon Linux 2 AMI for `us-east-1`). | `string`       | `"ami-053b0d53c279acc90"`    |
| `instance_type`       | The type of EC2 instance to provision. (Controlled by the module).              | `string`       | `"t2.micro"`               |
| `ingress_ports`       | A list of inbound ports to open on the security group for this Roboshop instance.| `list(number)` | `[22, 80, 443, 8080]`      |
| `key_name`            | The name of an existing EC2 Key Pair for SSH access.                            | `string`       | `null`                     |
| `security_group_name` | The name for the created security group for this Roboshop instance.             | `string`       | `null`                     |
| `region`              | The AWS region where resources will be deployed.                                | `string`       | `"us-east-1"`              |

*(**Note:** For a complete list of all input variables supported by the underlying `terraform-aws-instance` module, please refer to its dedicated repository's README.)*

## 7\. Outputs

Upon successful deployment, the `outputs.tf` file in this repository will display the following easily accessible information about the provisioned Roboshop EC2 instance:

| Name                    | Description                                       |
| :---------------------- | :------------------------------------------------ |
| `ec2_instance_id`       | The unique ID of the provisioned EC2 instance.    |
| `ec2_public_ip`         | The public IP address assigned to the EC2 instance.|
| `security_group_id`     | The ID of the created security group.             |

You can retrieve these output values at any time from your terminal using:

```bash
terraform output
```

To get a specific output (e.g., just the public IP):

```bash
terraform output ec2_public_ip
```

## 8\. Cleaning Up Resources

To gracefully remove all resources provisioned by this Terraform configuration from your AWS account, execute the `terraform destroy` command:

```bash
terraform destroy --auto-approve
```

*(As always, consider removing `--auto-approve` for critical environments to get a confirmation prompt before deletion.)*

## 9\. ⚡ Important Note on State Locking ⚡

This configuration utilizes an S3 bucket for remote state storage, which provides excellent durability, versioning, and encryption for your `terraform.tfstate` file.

**However, it is crucial to understand that an S3 bucket, when used in isolation, DOES NOT inherently provide state locking.**

  * **The Risk:** Without state locking, if multiple users or automated CI/CD pipelines attempt to run `terraform apply` concurrently against the *same state file*, it can lead to **state corruption**. This results in an inconsistent state file that misrepresents your actual infrastructure, potentially causing:
      * Errors during subsequent Terraform operations.
      * Creation of duplicate resources.
      * Unexpected deletion of existing resources.
      * "Phantom" resources (cloud resources not reflected in state, or vice-versa).
  * **The Recommendation:** For any team-based development, production deployments, or automated pipelines where state consistency is paramount, implementing a state locking mechanism is **highly recommended**. The most common and robust solution when using an S3 backend is to also provision and configure an **AWS DynamoDB table** specifically for state locking. DynamoDB provides a simple, consistent, and highly available lock, preventing simultaneous write operations to your state file.

While this example focuses on module consumption and S3 for state storage, be acutely aware of this limitation in a multi-user context.

## 10\. References

  * **Terraform AWS Instance Module:** This repository explicitly consumes the `terraform-aws-instance` module. You can find its source code and detailed documentation here:
      * [https://github.com/Nallagachu/terraform-aws-instance](https://www.google.com/search?q=https://github.com/Nallagachu/terraform-aws-instance)

## 11\. Contributing

Contributions, issues, and feature requests are always welcome\! Feel free to check the [issues page](https://www.google.com/search?q=https://github.com/Nallagachu/roboshop-ec2-test/issues) for this repository.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/your-roboshop-component`).
3.  Commit your changes (`git commit -m 'feat: Add new roboshop test component'`-like commits).
4.  Push to the branch (`git push origin feature/your-roboshop-component`).
5.  Open a Pull Request with a clear description of your changes.

## 12\. License

This project is open-sourced under the [MIT License](https://www.google.com/search?q=LICENSE). See the `LICENSE` file for more details.

## 13\. Contact

For any questions, feedback, or collaborations, feel free to reach out:

Nallagachu - [GitHub Profile](https://www.google.com/search?q=https://github.com/Nallagachu)

