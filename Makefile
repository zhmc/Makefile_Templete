# VPATH Makefile 寻找.c文件编译.o文件的目录
VPATH=./src/:./examples 
# 动态库
SLIB=libhello.so
# 静态库
ALIB=libhello.a
# 临时的.o文件存放位置
OBJDIR=./obj/

# 编译器
CC = g++
# archiver
AR=ar
ARFLAGS = rcs

# include目录
COMMON = -I./include/ -I./src/
# 编译参数
CFLAGS = -Wall -Wno-unused-result -Wno-unknown-pragmas -Wfatal-errors -fPIC
# 链接参数
LDFLAGS = -lpthread

# 源文件后缀（可以换成.cpp）
SOURCE_SUFFIX = .c
# 列出工作目录下所有以“.c”结尾的文件，以空格分隔，将文件列表赋给变量SOURCE
SOURCE := $(wildcard src/*$(SOURCE_SUFFIX))
# 调用patsubst函数，生成与源文件对应的“.o”文件列表
SRC_OBJ := $(patsubst %$(SOURCE_SUFFIX), %.o, $(SOURCE))
# 将src/前缀 替换为obj/前缀。 最终得到动态库、静态库依赖的.o集合
OBJS = $(SRC_OBJ:src/%=$(OBJDIR)%)

# 依赖的头文件
DEPS = $(wildcard src/*.h) $(wildcard include/*.h) Makefile


# 为example目录中所有.c文件都编译一个可执行文件
TARGET_SRCS := $(wildcard  examples/*$(SOURCE_SUFFIX))
PRGS := $(patsubst %$(SOURCE_SUFFIX), %, $(TARGET_SRCS))
# 去掉example/前缀
# 此处也可以将可执行文件放入build目录
BINS = $(PRGS:examples/%=%)

all: obj $(SLIB) $(ALIB) $(BINS) 

$(BINS): %: %$(SOURCE_SUFFIX)  $(ALIB)
	$(CC) $(COMMON) $(CFLAGS) $^ -o $@  $(LDFLAGS)

# $@表示目标（冒号左侧） $^ 表示依赖项（冒号右侧的）
$(ALIB): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^

$(SLIB): $(OBJS)
	$(CC) $(CFLAGS) -shared $^ -o $@ $(LDFLAGS)

# $< 表示依赖项的第一个
$(OBJDIR)%.o: %$(SOURCE_SUFFIX) $(DEPS)
	$(CC) $(COMMON) $(CFLAGS) -c $<  -o $@

obj:
	mkdir obj
	
clean:
	rm -rf $(SLIB) $(ALIB) $(BINS) $(OBJDIR)