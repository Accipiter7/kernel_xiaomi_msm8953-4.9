#!/usr/bin/env bash

git clone --depth 1 https://github.com/kdrag0n/proton-clang /pclang
git clone --depth 1 -j8 https://github.com/Accipiter7/AnyKernel3 -b mido /ak3

# Set Build Env

IMG=/src/out/arch/arm64/boot/Image.gz-dtb

TC_VER=$("/pclang/bin/clang" --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

BDT=$(date +"%h-%d-%H:%M")

export ARCH=arm64

export CC=/pclang/bin/clang 
export CROSS_COMPILE=/pclang/bin/aarch64-linux-gnu- 
export CROSS_COMPILE_ARM32=pclang/bin/arm-linux-gnueabi-
export LD_LIBRARY_PATH="/pclang/bin/../lib:$PATH"

function sendInfo() 

{

 curl -s -X POST https://api.telegram.org/bot"$BID"/sendMessage -d chat_id="$GID" -d "parse_mode=HTML" -d text="$(

  for POST in "${@}"; do

   echo "${POST}"

    done

     )" 

}

function sendLog() 

{

 curl -F chat_id="${GID}" -F document=@/build.log https://api.telegram.org/bot"$BID"/sendDocument

}

function sendZip()

{

 cd /ak3

 ZIP=$(echo *.zip)

 curl -F chat_id="${GID}" -F document="@$ZIP"  https://api.telegram.org/bot"${BID}"/sendDocument

}

function zipper()

{

 cp "${IMG}" /ak3

 cd /ak3

 make -j16

 mv Thy-Kernel.zip Thy-"${BDT}".zip

}

function success() 

{

 sendInfo "<b>Commit: </b><code>$(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>" \

          "<b>Compile Time: </b><code>$((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)</code>" \

          "<b>Toolchain:</b><code>${TC_VER}</code>" \

          "<b>THY SUCCESS</b>"

 sendLog

}

function failed() 

{

 sendInfo "<b>Commit:</b><code>$(git --no-pager log --pretty=format:'"%h - %s (%an)"' -1)</code>" \

          "<b> FAILED </b>" \

          "<b>Total Time Elapsed: </b><code>$((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds.</code>"

 sendLog

 exit 1;

 }

function compile() 

{

            cd /src  
            START=$(date +"%s")
	    make ARCH=arm64 mido_defconfig O=out 2> /build.log

		make O=out -j16 2>> /build.log \

			CC=/pclang/bin/clang \

			CROSS_COMPILE=/pclang/bin/aarch64-linux-gnu- \

			CROSS_COMPILE_ARM32=/pclang/bin/arm-linux-gnueabi-

		

if ! [ -a "$IMG" ] ; 

then																		

   END=$(date +"%s")

   DIFF=$((END - START))

   failed  

fi

  END=$(date +"%s")

  DIFF=$((END - START))

  success

  zipper

  sendZip

}

compile
