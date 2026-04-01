CC := x86_64-elf-gcc
LD := x86_64-elf-ld

kernel_source_files := $(shell find src/impl/kernel -name *.c)
kernel_object_files := $(patsubst src/impl/kernel/%.c, build/kernel/%.o, $(kernel_source_files))

x86_64_c_source_files := $(shell find src/impl/x86_64 -name *.c)
x86_64_c_object_files := $(patsubst src/impl/x86_64/%.c, build/x86_64/%.o, $(x86_64_c_source_files))

x86_64_asm_source_files := $(shell find src/impl/x86_64 -name *.asm)
x86_64_asm_object_files := $(patsubst src/impl/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

x86_64_object_files := $(x86_64_c_object_files) $(x86_64_asm_object_files)

CFLAGS := -ffreestanding -fno-stack-protector -fno-stack-check -fno-lto \
          -fno-PIC -ffunction-sections -fdata-sections \
          -m64 -march=x86-64 -mno-80387 -mno-mmx -mno-sse -mno-sse2 \
          -mno-red-zone -mcmodel=kernel

LDFLAGS := -nostdlib -static -z max-page-size=0x1000 --gc-sections

build/kernel/%.o: src/impl/kernel/%.c
	mkdir -p $(dir $@)
	$(CC) -c -I src/intf $(CFLAGS) $(patsubst build/kernel/%.o, src/impl/kernel/%.c, $@) -o $@

build/x86_64/%.o: src/impl/x86_64/%.c
	mkdir -p $(dir $@)
	$(CC) -c -I src/intf $(CFLAGS) $(patsubst build/x86_64/%.o, src/impl/x86_64/%.c, $@) -o $@

build/x86_64/%.o: src/impl/x86_64/%.asm
	mkdir -p $(dir $@)
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/impl/x86_64/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(kernel_object_files) $(x86_64_object_files)
	mkdir -p dist/x86_64
	$(LD) $(LDFLAGS) -o dist/x86_64/kernel.elf -T targets/x86_64/linker.ld \
      $(kernel_object_files) $(x86_64_object_files)
	cp dist/x86_64/kernel.elf targets/x86_64/iso/boot/kernel.elf
	xorriso -as mkisofs \
	  -b boot/limine/limine-bios-cd.bin \
	  -no-emul-boot -boot-load-size 4 -boot-info-table \
	  --efi-boot boot/limine/limine-uefi-cd.bin \
	  -efi-boot-part --efi-boot-image --protective-msdos-label \
	  targets/x86_64/iso -o dist/x86_64/kernel.iso
	./limine/limine bios-install dist/x86_64/kernel.iso

.PHONY: run
run:
	qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso -m 256M

.PHONY: clean
clean:
	rm -rf build dist