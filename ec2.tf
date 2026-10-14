resource "aws_instance" "example" {
  ami                         = "ami-01a00762f46d584a1"
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_default_security_group.default.id]
  key_name               = "portfolio-key"

  tags = {
    Name = "portfolio-EC2"
  }

  # Connect to the EC2 instance through SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/portfolio-key.pem")
    host        = self.public_ip
    timeout     = "5m"
  }

  # Install Nginx and deploy the portfolio
  provisioner "remote-exec" {
    inline = [
      "set -e",

      # Update Ubuntu packages
      "sudo apt-get update -y",

      # Install Nginx, Git and rsync
      "sudo apt-get install -y nginx git rsync",

      # Start Nginx automatically
      "sudo systemctl enable --now nginx",

      # Clone the repository if it does not exist;
      # otherwise update the existing repository
      "if [ -d /home/ubuntu/portfolio/.git ]; then sudo git -C /home/ubuntu/portfolio fetch origin main && sudo git -C /home/ubuntu/portfolio reset --hard origin/main; else sudo git clone --branch main https://github.com/Sindhupothuri99/git-portfolio.git /home/ubuntu/portfolio; fi",

      # Copy the portfolio subfolder into Nginx
      "sudo rsync -a --delete --exclude='.git' /home/ubuntu/portfolio/portfolio/ /var/www/html/",

      # Set file ownership and permissions
      "sudo chown -R www-data:www-data /var/www/html",
      "sudo find /var/www/html -type d -exec chmod 755 {} +",
      "sudo find /var/www/html -type f -exec chmod 644 {} +",

      # Validate and restart Nginx
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
  }
}
