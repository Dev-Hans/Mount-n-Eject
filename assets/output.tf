output "public_snapshot_id" {
  description = "The ID of the publicly shared EBS snapshot for the CTF challenge. Provide this to the participants."
  value       = aws_ebs_snapshot.challenge_snapshot.id
}

output "instance_id" {
  description = "The ID of the EC2 instance used to build the snapshot."
  value       = aws_instance.mount_ec2.id
}