#!/bin/bash
#
# by Minhker
# MinhKer Build Script V10 for m51

# Main Dir
WIN_OUT_DIR=/home/m/share/KERNEL
KERNEL_OUT=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DTBO_OUT=$(pwd)/out/arch/arm64/boot/dtbo.img
KERNEL_MK=$(pwd)/MK/MinhKer_kernel_R_M51/Image.gz-dtb
DTBO_MK=$(pwd)/MK/MinhKer_kernel_R_M51/dtbo.img
VERSION=V2
NAME=MinhKer_R
DATE=$(date +%Y%m%d)
#CONFIG=sm7150_sec_m51_eur_open_defconfig
VARIANT=M515
export USE_CCACHE=1
# Export CCACHE
export CCACHE="$(which ccache)"
export USE_CCACHE=1
ccache -M 20G
export CCACHE_COMPRESS=1
export CROSS_COMPILE=/mnt/e/KERNEL/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export REAL_CC=/mnt/e/KERNEL/llvm-arm-toolchain-ship-10.0/bin/clang
export ARCH=arm64
read -p "Clean source (y/n) > " yn
if [ "$yn" = "Y" -o "$yn" = "y" ]; then
     echo "Clean Build"   
	#cd $(pwd)/out 
   	make clean
	rm $KERNEL_MK
    	rm $MK_DTBO
	rm $(pwd)/out/arch/arm64/boot/dts/qcom/sdmmagpie.dtb
	rm -rf ./out
	rm $(pwd)/MK/AIK-Linux/image-new.img
	mkdir out
#else
#    mkdir out       
fi
BUILD_CROSS_COMPILE=/mnt/e/KERNEL/aarch64-linux-android-4.9/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=/mnt/e/KERNEL/llvm-arm-toolchain-ship-10.0/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"
        echo "Starting $VARIANT Image.gz-dtb kernel build..."
	    rm $KERNEL_OUT $DTBO_OUT
	    rm -rf $(pwd)/out/arch/arm64/boot/dts
	    export LOCALVERSION=-$NAME-$VERSION-$VARIANT-$DATE	
BUILD_1()	
{
	    make -C $(pwd) O=$(pwd)/out  ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE sm7150_sec_m51_eur_open_defconfig
	    make -j8 -C $(pwd) O=$(pwd)/out  ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE
}
	    BUILD_1
BUILD_2()
{
		export ARCH=arm64
                make -C $(pwd) O=$(pwd)/out CLANG_TRIPLE=aarch64-linux-gnu- sm7150_sec_m51_eur_open_defconfig
                make -j8 -C $(pwd) O=$(pwd)/out CLANG_TRIPLE=aarch64-linux-gnu-
}	   
	    #BUILD_2
BUILD_DTBO()
{
	    rm $DTBO_MK
            echo "Starting $VARIANT dtbo.img build..."
	    tools/mkdtimg create $DTBO_OUT --page_size=4096 $(find out -name "*.dtbo")
} 
	  #  BUILD_DTBO
CREATE_FLASHBLE_ZIP()
{	    
	    rm $KERNEL_MK
	    cp $KERNEL_OUT $KERNEL_MK
	    cp $DTBO_OUT $DTBO_MK
	    rm -rfv $(find MK/MinhKer_kernel_R_M51 -name "*.zip")
	    echo " Create anykernel3 flashable zip"
	    ./MK/MinhKer_kernel_R_M51/zip.sh
	    cp -r $(pwd)/MK/MinhKer_kernel_R_M51 $WIN_OUT_DIR
}
	   # CREATE_FLASHBLE_ZIP
CREATE_FLASHBLE_ZIP2()
{	    
	    rm /mnt/e/KERNEL/MinhKer_kernel_R_M51/Image.gz-dtb
	    cp $KERNEL_OUT /mnt/e/KERNEL/MinhKer_kernel_R_M51/Image.gz-dtb
	   # cp $DTBO_OUT $DTBO_MK
	    rm -rfv $(find /mnt/e/KERNEL/MinhKer_kernel_R_M51 -name "*.zip")
	    echo " Create anykernel3 flashable zip"
		#u=$(pwd)
		cd /mnt/e/KERNEL/MinhKer_kernel_R_M51
	    ./zip.sh
		#cd u
	   # cp -r $(pwd)/MK/MinhKer_kernel_R_M51 $WIN_OUT_DIR
}
	   CREATE_FLASHBLE_ZIP2
PACK_BOOT_IMG()
{
	    echo "Building Boot.img for $MK_VARIANT"
	    rm $(pwd)/MK/AIK-Linux/image-new.img
	    rm $(pwd)/MK/AIK-Linux/split_img/boot.img-dtb
	    cp $(pwd)/out/arch/arm64/boot/dts/qcom/sdmmagpie.dtb $(pwd)/MK/AIK-Linux/split_img/boot.img-dtb
	    #cp $KERNEL_OUT $(pwd)/MK/AIK-Linux/split_img/boot.img-kernel
	    cd MK
	    cd AIK-Linux
	    ./repackimg.sh
	    echo "coping boot.img... to..."
	    cd ..
	    cd ..
	    cp $(pwd)/MK/AIK-Linux/image-new.img  $WIN_OUT_DIR/MinhKer_kernel_R_M51/boot_m51_dtb.img
}
	   # PACK_BOOT_IMG
	    echo "$VARIANT Image.gz-dtb dtbo.img boot.img build coppy and zip finished."