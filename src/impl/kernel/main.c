#include <stdint.h>

struct limine_hhdm_response {
    uint64_t revision;
    uint64_t offset;
};

struct limine_hhdm_request {
    uint64_t id[4];
    uint64_t revision;
    struct limine_hhdm_response *response;
};

// magic nums
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
    if (hhdm_request.response == 0) {
        for (;;) __asm__("hlt"); // hang safely if limine didnt fill it
    }

    print("Hello, World!", hhdm_request.response->offset);

    for (;;) __asm__("hlt");
}