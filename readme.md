# Bộ Terraform AWS Infrastructure

Đây là bộ mã Terraform để triển khai cơ sở hạ tầng AWS hoàn chỉnh cho ứng dụng đa tầng, sử dụng các module chính thức của AWS. Mục tiêu là cung cấp môi trường cơ sở hạ tầng cloud theo tiêu chuẩn production, đáp ứng các yêu cầu về bảo mật, khả năng mở rộng và tính sẵn sàng cao.

## Tổng quan

Dự án này sử dụng Terraform để quản lý infrastructure-as-code (IaC) cho AWS, cho phép triển khai và quản lý cơ sở hạ tầng cloud một cách nhất quán và có thể lặp lại. Các module AWS chính thức được sử dụng để đảm bảo tuân thủ các best practices.

## Các dịch vụ AWS được triển khai

Bộ Terraform này triển khai các dịch vụ AWS sau:

### Mạng và bảo mật
- **VPC**: Mạng ảo riêng với public, private và database subnets
- **Route 53**: Quản lý DNS và domain
- **ACM**: Quản lý SSL/TLS certificates
- **Security Groups**: Kiểm soát traffic giữa các dịch vụ
- **WAF**: Web Application Firewall để bảo vệ ứng dụng web

### Compute
- **EC2**: Máy chủ ảo cho các ứng dụng truyền thống
- **EKS**: Kubernetes được quản lý cho các ứng dụng containerized
- **Lambda**: Hàm serverless cho kiến trúc event-driven

### Database và Storage
- **RDS**: Cơ sở dữ liệu quan hệ có khả năng mở rộng (MySQL/PostgreSQL)
- **DynamoDB**: Cơ sở dữ liệu NoSQL có hiệu suất cao
- **S3**: Lưu trữ đối tượng linh hoạt và có chi phí thấp
- **ElastiCache (Redis)**: Lưu trữ dữ liệu trong bộ nhớ cache

### Điều phối tải và phân phối nội dung
- **ALB**: Application Load Balancer để điều phối traffic
- **CloudFront**: CDN để phân phối nội dung tĩnh

### Container và Registry
- **ECR**: Elastic Container Registry để lưu trữ Docker images
- **EBS CSI Driver**: Cho phép sử dụng Persistent Volume Claims (PVC) trong EKS

### Monitoring và Messaging
- **CloudWatch**: Giám sát và cảnh báo
- **SQS**: Hàng đợi tin nhắn cho xử lý bất đồng bộ

### Quản lý bí mật và xác thực
- **IAM**: Quản lý quyền truy cập
- **Secrets Manager**: Lưu trữ an toàn thông tin nhạy cảm

### API và Serverless
- **API Gateway**: Quản lý APIs
- **Lambda**: Hàm serverless

## Cấu trúc dự án

```
terraform-aws-infrastructure/
├── main.tf           # Cấu hình chính cho các module
├── variables.tf      # Định nghĩa các biến đầu vào
├── outputs.tf        # Định nghĩa các đầu ra
├── provider.tf       # Cấu hình AWS provider
├── terraform.tfvars  # File giá trị biến (không nên commit lên git)
├── lambda/           # Thư mục chứa mã nguồn cho Lambda functions
└── README.md         # Tài liệu dự án
```

## Yêu cầu tiên quyết

- Terraform v1.0.0 trở lên
- Tài khoản AWS với quyền quản trị viên
- AWS CLI đã được cài đặt và cấu hình
- (Tùy chọn) S3 bucket và DynamoDB table cho Terraform backend

## Hướng dẫn sử dụng

### 1. Cài đặt Terraform

Nếu bạn chưa cài đặt Terraform, vui lòng làm theo [hướng dẫn cài đặt chính thức](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### 2. Cấu hình AWS Credentials

Đảm bảo AWS credentials của bạn được cấu hình đúng:

```bash
aws configure
```

### 3. Tùy chỉnh biến

Tạo file `terraform.tfvars` để cung cấp giá trị cho các biến:

```hcl
aws_region        = "ap-southeast-1"
environment       = "dev"
vpc_name          = "my-vpc"
vpc_cidr          = "10.0.0.0/16"
public_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets   = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
domain_name       = "example.com"
```

### 4. Khởi tạo Terraform

```bash
terraform init
```

Nếu bạn sử dụng S3 backend, hãy chỉnh sửa phần `backend "s3"` trong `provider.tf` trước khi chạy `terraform init`.

### 5. Xem trước thay đổi

```bash
terraform plan
```

### 6. Triển khai cơ sở hạ tầng

```bash
terraform apply
```

Xem xét các thay đổi được đề xuất và gõ `yes` để tiếp tục.

### 7. Dọn dẹp tài nguyên

Khi bạn không còn cần cơ sở hạ tầng này:

```bash
terraform destroy
```

## Tùy chỉnh cấu hình

### Thay đổi môi trường

Để triển khai cho các môi trường khác nhau (dev, staging, prod), hãy sử dụng các workspace của Terraform:

```bash
# Tạo workspace mới
terraform workspace new prod

# Chọn workspace
terraform workspace select prod

# Kiểm tra workspace hiện tại
terraform workspace show
```

Sau đó, tạo các file biến riêng biệt cho từng môi trường:
- `terraform.tfvars` (dev)
- `terraform.staging.tfvars` (staging)
- `terraform.prod.tfvars` (prod)

Và áp dụng với:

```bash
terraform apply -var-file=terraform.prod.tfvars
```

### VPC

Tùy chỉnh cấu hình VPC trong biến:

```hcl
vpc_cidr          = "10.0.0.0/16"
public_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets   = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
```

### RDS

Điều chỉnh các tham số RDS:

```hcl
rds_engine         = "postgres"
rds_engine_version = "14.5"
rds_instance_class = "db.t3.large"
```

### EKS

Tùy chỉnh cluster Kubernetes:

```hcl
cluster_name    = "production-cluster"
eks_version     = "1.28"
instance_types  = ["t3.large"]
```

## Biến môi trường

Dưới đây là danh sách các biến quan trọng trong dự án:

| Biến | Mô tả | Giá trị mặc định |
|------|--------|----------------|
| `aws_region` | AWS region | "ap-southeast-1" |
| `environment` | Môi trường (dev, staging, prod) | "dev" |
| `vpc_cidr` | CIDR cho VPC | "10.0.0.0/16" |
| `public_subnets` | Danh sách CIDR cho public subnets | ["10.0.1.0/24", ...] |
| `private_subnets` | Danh sách CIDR cho private subnets | ["10.0.4.0/24", ...] |
| `availability_zones` | Danh sách AZs | ["ap-southeast-1a", ...] |
| `cluster_name` | Tên cluster EKS | "main-eks-cluster" |
| `eks_version` | Phiên bản Kubernetes | "1.28" |
| `rds_engine` | Loại database engine | "mysql" |
| `rds_engine_version` | Phiên bản database | "8.0" |
| `domain_name` | Tên miền cho Route 53 và ACM | "example.com" |

## Best Practices

1. **Bảo mật trạng thái Terraform**:
   - Luôn sử dụng remote state (S3 + DynamoDB)
   - Bật mã hóa cho S3 bucket
   - Hạn chế quyền truy cập vào backend

2. **Quản lý biến nhạy cảm**:
   - Không lưu trữ thông tin nhạy cảm trong file `.tfvars`
   - Sử dụng AWS Secrets Manager hoặc biến môi trường
   - Đánh dấu biến nhạy cảm với `sensitive = true`

3. **Tổ chức mã**:
   - Tách cấu hình thành các module nhỏ hơn khi mở rộng
   - Sử dụng các tags nhất quán cho tất cả các tài nguyên
   - Tuân theo quy ước đặt tên rõ ràng

4. **Version Control**:
   - Commit `*.tf` files
   - Không commit `terraform.tfvars` và `.terraform/`
   - Sử dụng gitignore: `.gitignore`

## Xử lý sự cố

### State bị lock
Nếu state bị lock do người khác đang chạy Terraform hoặc do quá trình bị gián đoạn:

```bash
terraform force-unlock LOCK_ID
```

### Lỗi khi áp dụng
1. Kiểm tra xem AWS credentials có hợp lệ không
2. Xác minh rằng bạn có đầy đủ quyền trong IAM
3. Kiểm tra giới hạn service quotas
4. Xem nhật ký Terraform chi tiết: `TF_LOG=DEBUG terraform apply`

### Khôi phục từ state cũ
```bash
terraform state pull > terraform.tfstate.backup
terraform state push terraform.tfstate.backup
```

## Liên hệ và hỗ trợ

Nếu bạn có câu hỏi hoặc cần hỗ trợ với bộ Terraform này, vui lòng liên hệ:

- Email: your-email@example.com
- GitHub Issues: [Link tới GitHub repository]

---

## Giấy phép

MIT License

Copyright (c) 2025 [Tên của bạn]
