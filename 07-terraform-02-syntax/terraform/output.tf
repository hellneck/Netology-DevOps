output "account_id" {
    value = "${data.yandex_iam_service_account.admin.service_account_id}"
}

output "user_id" {
    value = "${data.yandex_iam_user.admin.user_id}"
}

output "zone_netology" {
    value = "${yandex_compute_instance.netology.zone}"
}

output "internal_ip_address_netology" {
    value = "${yandex_compute_instance.netology.network_interface.0.ip_address}"
}

output "network_id_netology" {
    value = "${yandex_compute_instance.netology.network_interface.0.subnet_id}"
}