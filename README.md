# Домашнее задание к занятию "`9.4 Отказоустройчивость в облаке`" - `Коротков Андрей`


### Задание 1 

Возьмите за основу [решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке»](https://github.com/netology-code/sdvps-homeworks/blob/main/7-03.md#задание-1).

1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:

- создаст 2 идентичные виртуальные машины. Используйте аргумент [count](https://www.terraform.io/docs/language/meta-arguments/count.html) для создания таких ресурсов;
- создаст [таргет-группу](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group). Поместите в неё созданные на шаге 1 виртуальные машины;
- создаст [сетевой балансировщик нагрузки](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer), который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин.

Рекомендуем изучить [документацию сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart) для того, чтобы было понятно, что вы сделали.

2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active,
- обе виртуальные машины в целевой группе находятся в состоянии healthy.

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

*В качестве результата пришлите:*

*1. Terraform Playbook.*

*2. Скриншот статуса балансировщика и целевой группы.*

*3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика.*

### Ответ 1

Для развертывания веб-серверов я использовал переменную "web_server_count", которая подставляется в "count" при осписании виртульных машин.
При описании target group я использовал вложенный dynamic блок бля создания необходимого количества target:

```hcl
resource "yandex_lb_target_group" "web-tg" {
  name      = "web-target-group"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.web

    content {
      subnet_id = target.value.network_interface[0].subnet_id
      address   = target.value.network_interface[0].ip_address
    }
  }
}
```

Такой подход посволяет гибко задавать необходимое количество веб-серверов значением одной переменной.

Веб-сервер Nginx устанавливается автоматически с помощью cloud-init:

```yaml
repo_update: true
repo_upgrade: true
apt:
  preserve_sources_list: true

packages:
  - nginx

runcmd:
  - [ systemctl, nginx-reload ]
  - [ systemctl, enable, nginx.service ]
  - [ systemctl, start, --no-block, nginx.service ]
  - [ sh, -c, "echo $(hostname | cut -d '.' -f 1 ) > /var/www/html/index.html" ]
```

Главная страница Nginx отображает хостнейм сервера.

[Terraform playbook](https://github.com/aniljich/9.4/blob/main/Terraform/machines.tf) с описанием виртуальных машин
[Terraform файл](https://github.com/aniljich/9.4/blob/main/load_balancer.tf) с описанием балансировщика

Скриншот балансировщика:<br>
![Load_balancer](https://github.com/aniljich/9.4/blob/main/img/image1.png)

Скриншот таргет-группы:<br>
![Targer_group](https://github.com/aniljich/9.4/blob/main/img/image2.png)

Скриншот веб-страницы:<br>
![Page](https://github.com/aniljich/9.4/blob/main/img/image3.png)
---
