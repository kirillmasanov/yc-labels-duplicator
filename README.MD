### K8s Labels Duplicator

Данный terraform-проект развертывает в *Yandex Cloud* функцию, которая вызывается по расписанию и копирует метки (*labels*) node-групп кластеров *mk8s* на нужные ресурсы (соответсвующие группам нод ВМ, загрузочные диски этих ВМ, ноды кластера k8s). 
*node_labels* (Метки узла) - это пользовательские метки, которые назначаются на группы узлов *Managed Service for Kubernetes* в *Yandex Cloud* (подробнее в [документации](https://yandex.cloud/ru/docs/managed-kubernetes/operations/node-group/node-label-management#node-group-creation))
*node_labels* используются в проекте для автоматического добавления меток на ноды кластера k8s.

---

### Функционал

- Создаёт сервисный аккаунт с набором IAM ролей для доступа к необходимым ресурсам
- Загружает и развёртывает функцию на базе кода из папки `code/`
- Настраивает триггер, запускающий функцию по расписанию (ежеминутно)
- Генерирует уникальные имена ресурсов с помощью случайной строки для избежания конфликтов

---
### Использование

1. Установите [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
2. Добавьте переменные окружения для аутентификации *terraform* в *Yandex Cloud*
```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```
3. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/kirillmasanov/yc-labels-duplicator
   cd yc-labels-duplicator
   ```
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