---
layout: post
title: 创建字符设备的三种方法
type: post
categories:
- Linux
tags: []
---

将创建字符设备的三种方法记录一下,以便以后参考.

<!--more-->

1. 使用早期的register_chardev()方法

```cpp
#include<linux/kernel.h>
#include<linux/module.h>
#include<linux/fs.h>
#include<asm/uaccess.h>

int init_module(void);
void cleanup_module(void);
static int device_open(struct inode*, struct file*);
static int device_release(struct inode*, struct file*);
static ssize_t device_read(struct file*, char *, size_t, loff_t*);
static ssize_t device_write(struct file*, const char*, size_t, loff_t*);

#define SUCCESS 0
#define DEVICE_NAME "chardev"
#define BUF_LEN 80

static int major;
static int Device_open = 0;
static char msg[BUF_LEN];
static char *msg_ptr;

static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
};
int init_module(void) {
    major = register_chrdev(0, DEVICE_NAME, &fops);
    if (major < 0) {
        printk(KERN_ALERT "Registering char device failed with %dn", major);
        return major;
    }
    printk(KERN_INFO "I was assigned major number %d.n", major);
    return SUCCESS;
}
void cleanup_module(void) {
    int ret = unregister_chrdev(major, DEVICE_NAME);
    if (ret < 0)
        printk(KERN_ALERT "Error in unregister chrdev %dn", major);
}
static int device_open(struct inode* inode, struct file* file) {
    static int counter = 0;
    if (Device_open)
        return -EBUSY;
    Device_open++;
    sprintf(msg, "I already told you %d times hello worldnDevice_open=%dn",
        counter++, Device_open);
    msg_ptr = msg;
    try_module_get(THIS_MODULE);
    return SUCCESS;
}
static int device_release(struct inode* inode, struct file* file) {
    Device_open--;
    module_put(THIS_MODULE);
    return 0;
}
static ssize_t device_read(struct file* filp, char *buffer, size_t length, loff_t *offset)
{
    int bytes_read = 0;
    if (*msg_ptr == '') return 0;
    printk(KERN_ALERT "length=%dn", length);
    while (length && *msg_ptr) {
        put_user(*(msg_ptr++), buffer++);
        length--;
        bytes_read++;
    }
    return bytes_read;
}
static ssize_t device_write(struct file* filp, const char *buff, size_t len, loff_t *off)
{
    printk(KERN_ALERT "Sorry, this operation isn't supportedn");
    return -EINVAL;
}
```

2. 使用cdev的方法

```cpp
#include<linux/kernel.h>
#include<linux/module.h>
#include<linux/fs.h>
#include<linux/types.h>
#include<linux/fs.h>
#include<linux/cdev.h>
#include<asm/uaccess.h>

int init_module(void);
void cleanup_module(void);
static int device_open(struct inode*, struct file*);
static int device_release(struct inode*, struct file*);
static ssize_t device_read(struct file*, char *, size_t, loff_t*);
static ssize_t device_write(struct file*, const char*, size_t, loff_t*);

#define SUCCESS 0
#define DEVICE_NAME "chardev"
#define BUF_LEN 80

static int major;
static int Device_open = 0;
static char msg[BUF_LEN];
static char *msg_ptr;
static struct cdev *my_cdev;
static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
};
int init_module(void) {
    int err;
    dev_t devid ;
    alloc_chrdev_region(&devid, 0, 1, "chardev");
    major = MAJOR(devid);
    my_cdev = cdev_alloc();
    cdev_init(my_cdev, &fops);
    err = cdev_add(my_cdev, devid, 1);
    if (err) {
        printk(KERN_INFO "I was assigned major number %d.n", major);
        return -1;
    }
    printk("major number is %dn", MAJOR(devid));
    return SUCCESS;
}
void cleanup_module(void) {
    cdev_del(my_cdev);
    printk("cleanup donen");
}
static int device_open(struct inode* inode, struct file* file) {
    static int counter = 0;
    if (Device_open) return -EBUSY;
    Device_open++;
    sprintf(msg, "I already told you %d times hello worldnDevice_open=%dn",
        counter++, Device_open);
    msg_ptr = msg;
    try_module_get(THIS_MODULE);
    return SUCCESS;
}
static int device_release(struct inode* inode, struct file* file) {
    Device_open--; module_put(THIS_MODULE); return 0;
}
static ssize_t device_read(struct file* filp, char *buffer, size_t length, loff_t *offset)
{
    int bytes_read = 0;
    if (*msg_ptr == '') return 0;
    printk(KERN_ALERT "length=%dn", length);
    while (length && *msg_ptr)
        { put_user(*(msg_ptr++), buffer++); length--; bytes_read++; }
    return bytes_read;
}
static ssize_t device_write(struct file* filp, const char *buff, size_t len, loff_t *off)
{ printk(KERN_ALERT "Sorry, this operation isn't supportedn"); return -EINVAL; }
```

3. 使用udev在/dev/下动态生成设备文件的方式

```cpp
#include<linux/kernel.h>
#include<linux/module.h>
#include<linux/types.h>
#include<linux/fs.h>
#include<linux/cdev.h>
#include<linux/pci.h>
#include<linux/moduleparam.h>
#include<linux/init.h>
#include<linux/string.h>
#include<asm/uaccess.h>
#include<asm/unistd.h>
#include<asm/uaccess.h>

MODULE_LICENSE("GPL"); /*此处如果不加的话加载的时候会出错*/

int init_module(void);
void cleanup_module(void);
static int device_open(struct inode*, struct file*);
static int device_release(struct inode*, struct file*);
static ssize_t device_read(struct file*, char *, size_t, loff_t*);
static ssize_t device_write(struct file*, const char*, size_t, loff_t*);

#define SUCCESS 0
#define DEVICE_NAME "chardev"
#define BUF_LEN 80

static int major;
static int Device_open = 0;
static char msg[BUF_LEN];
static char *msg_ptr;
static struct cdev *my_cdev;
static struct class *my_class;
dev_t devid ;

static struct file_operations fops = {
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release,
};
int init_module(void) {
    int err;
    alloc_chrdev_region(&devid, 0, 1, "chardev");
    major = MAJOR(devid);
    my_cdev = cdev_alloc();
    cdev_init(my_cdev, &fops);
    my_cdev->owner = THIS_MODULE;
    err = cdev_add(my_cdev, devid, 1);
    if (err) {
        printk(KERN_INFO "I was assigned major number %d.n", major);
        return -1;
    }
    my_class = class_create(THIS_MODULE, "chardev_class1");
    if (IS_ERR(my_class)) {
        printk(KERN_INFO "create class errorn");
        return -1;
    }
    class_device_create(my_class, NULL, devid, NULL, "chardev" "%d", MINOR(devid));
    printk("major number is %dn", MAJOR(devid));
    return SUCCESS;
}
void cleanup_module(void) {
    cdev_del(my_cdev);
    class_device_destroy(my_class, devid);
    class_destroy(my_class);
    printk("cleanup donen");
}
static int device_open(struct inode* inode, struct file* file) {
    static int counter = 0;
    if (Device_open) return -EBUSY;
    Device_open++;
    sprintf(msg, "I already told you %d times hello worldnDevice_open=%dn",
        counter++, Device_open);
    msg_ptr = msg;
    try_module_get(THIS_MODULE);
    return SUCCESS;
}
static int device_release(struct inode* inode, struct file* file)
{ Device_open--; module_put(THIS_MODULE); return 0; }
static ssize_t device_read(struct file* filp, char *buffer, size_t length, loff_t *offset)
{
    int bytes_read = 0;
    if (*msg_ptr == '') return 0;
    printk(KERN_ALERT "length=%dn", length);
    while (length && *msg_ptr)
        { put_user(*(msg_ptr++), buffer++); length--; bytes_read++; }
    return bytes_read;
}
static ssize_t device_write(struct file* filp, const char *buff, size_t len, loff_t *off)
{ printk(KERN_ALERT "Sorry, this operation isn't supportedn"); return -EINVAL; }
```
