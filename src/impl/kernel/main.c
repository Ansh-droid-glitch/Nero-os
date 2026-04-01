#include <stdint.h>

// Request start/end anchors required by Limine v5+
__attribute__((used, section(".limine_requests_start")))
static volatile uint64_t limine_requests_start_marker[] = {
    0xf6b8f4b39de7d1ae, 0xfab91a6940fcb9cf
};

__attribute__((used, section(".limine_requests_end")))
static volatile uint64_t limine_requests_end_marker[] = {
    0x854c3a44, 0xb459a09e
};

// Base revision (tell Limine we support revision 2)
__attribute__((used, section(".limine_requests")))
static volatile uint64_t limine_base_revision[] = {
    0xf9562b2d, 0x07ab71e5, 2
};

// HHDM request
struct limine_hhdm_response {
    uint64_t revision;
    uint64_t offset;
};

struct limine_hhdm_request {
    uint64_t id[4];
    uint64_t revision;
    struct limine_hhdm_response *response;
};

__attribute__((used, section(".limine_requests")))
static volatile struct limine_hhdm_request hhdm_request = {
    .id = {
        0xc7b1dd30df4c8b88,
        0x0a82e883a194f07b,
        0x48dcf1cb8ad2b852,
        0x63984e959a98244b
    },
    .revision = 0,
    .response = 0
};

static void print(const char *str, uint64_t hhdm_offset) {
    volatile uint16_t *vga = (volatile uint16_t *)(hhdm_offset + 0xB8000);
    uint8_t color = 0x0F;
    for (int i = 0; str[i] != '\0'; i++) {
        vga[i] = (uint16_t)str[i] | ((uint16_t)color << 8);
    }
}

void kernel_main(void) {
    if (hhdm_request.response == 0)
        for (;;) __asm__("hlt");

    print("Hello, World!", hhdm_request.response->offset);

    for (;;) __asm__("hlt");
}