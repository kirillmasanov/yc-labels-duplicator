### Labels Duplicator

Данный проект автоматизирует развёртывание облачной функции в _Yandex Cloud_, которая периодически запускается и копирует метки (_node_labels_) на нужные ресурсы (ВМ, загрузочные диски).

_node_labels_ (Метки узла) - это пользовательские метки, которые назначаются на группы узлов _Managed Service for Kubernetes_ в _Yandex Cloud_ (подробнее в [документации](https://yandex.cloud/ru/docs/managed-kubernetes/operations/node-group/node-label-management#node-group-creation))

---

### Функционал

- Создаёт сервисный аккаунт с набором IAM ролей для доступа к необходимым ресурсам
- Загружает и развёртывает функцию на базе кода из папки `code/`
- Настраивает триггер, запускающий функцию по расписанию (ежеминутно)
- Генерирует уникальные имена ресурсов с помощью случайной строки для избежания конфликтов

---
### Использование

1. Установите [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
2. Добавьте переменные окружения для аутентификации terraform в Yandex Cloud
```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```
3. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/kirillmasanov/yc-labels-duplicator
   cd yc-labels-duplicator
4. Настройте файл `terraform.tfvars` или передайте необходимые переменные вручную. Например, создайте `terraform.tfvars`:
```bash
folder_id = "your-folder-id"
```
5. Инициализируйте Terraform:
```tf
terraform init
```
6. Проверьте план:
```tf
terraform plan
```
7. Примените конфигурацию:
```tf
terraform apply
```