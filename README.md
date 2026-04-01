# Mount-n-Eject
Village: Cloud Village  
Conference: DEF CON Bahrain 2025  
Contributor: [Hans Raj Shrivastava](https://www.linkedin.com/in/hans-infosec/)

## Cloud Service Provider Used
AWS

## Story
A former developer took an emergency snapshot of a production server's root volume right before quitting to create a backup. In their haste, they accidentally set the snapshot permissions to public and shared the ID with the world before AWS security caught it. We need to see what sensitive information was exposed. The flag is hidden inside the snapshot, disguised as a routine system backup log.

## Entrypoint
Snapshot ID: snap-0ee74f7d82b77d8ec

## Flag
FLAG-{AD7dA2a7a4Ea5C23A83c4b887c8C26D7}

## Points & Difficulty
100 - Easy

## Hints
1. Try mounting the volume.
2. Did you check logs?

## Service Used
1. EC2 Instance
2. EBS Volume Snapshot

## Solution
Refer /solution directory.

## Implementation Details
This Terraform script automates the creation of a public AWS snapshot containing a hidden flag.  
It performs the following actions:

1. **Launches an EC2 Instance**  
   - Starts a free-tier eligible Ubuntu instance in the **us-west-2** region.

2. **Hides the Flag**  
   - Connects to the instance via SSH.  
   - Writes a flag into the `/var/log/flag.txt` file on the root volume.

3. **Stops the Instance**  
   - Ensures a consistent filesystem state by stopping the instance gracefully.

4. **Creates a Snapshot**  
   - Generates a snapshot of the instance’s root volume.

5. **Makes it Public**  
   - Updates the snapshot’s permissions to make it publicly accessible to all AWS users.

6. **Outputs the Snapshot ID**  
   - Displays the `public_snapshot_id` — the key piece of information for CTF participants.

---

## 🧰 Prerequisites

Before running the Terraform script, ensure the following are installed and configured:

- **Terraform**
- **AWS CLI**
- **AWS Credentials** configured in your environment  

You can set the credentials using environment variables:

```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
export AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"
```

## Initialize Terraform
Open your terminal, navigate to the /assets directory with these files, and run:

`terraform init`

## Deploy the Challenge
Apply the Terraform configuration. This will create all the necessary AWS resources.

`terraform apply`


Get the Snapshot ID:
After the deployment is complete, Terraform will display the public_snapshot_id in the output. This is the ID you will provide to the CTF participants.

## Cleaning Up
To tear down the challenge and remove all created AWS resources (instance, key pair, security group, and snapshot), simply run:

`terraform destroy`
