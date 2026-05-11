
my_soc_firmware.elf:     file format elf32-littleriscv


Disassembly of section .text:

00010000 <_start>:
   10000:	30001073          	csrw	mstatus,zero
   10004:	30401073          	csrw	mie,zero
   10008:	000062b7          	lui	t0,0x6
   1000c:	3002a073          	csrs	mstatus,t0
   10010:	00301073          	fscsr	zero
   10014:	20010117          	auipc	sp,0x20010
   10018:	fec10113          	addi	sp,sp,-20 # 20020000 <_estack>
   1001c:	1fff0517          	auipc	a0,0x1fff0
   10020:	fe450513          	addi	a0,a0,-28 # 20000000 <huart0>
   10024:	1fff0597          	auipc	a1,0x1fff0
   10028:	fdc58593          	addi	a1,a1,-36 # 20000000 <huart0>
   1002c:	00001617          	auipc	a2,0x1
   10030:	ae060613          	addi	a2,a2,-1312 # 10b0c <_etext>

00010034 <copy_data_loop>:
   10034:	00b55c63          	bge	a0,a1,1004c <copy_data_done>
   10038:	00062283          	lw	t0,0(a2)
   1003c:	00552023          	sw	t0,0(a0)
   10040:	00450513          	addi	a0,a0,4
   10044:	00460613          	addi	a2,a2,4
   10048:	fedff06f          	j	10034 <copy_data_loop>

0001004c <copy_data_done>:
   1004c:	1fff0517          	auipc	a0,0x1fff0
   10050:	fb450513          	addi	a0,a0,-76 # 20000000 <huart0>
   10054:	1fff0597          	auipc	a1,0x1fff0
   10058:	fbc58593          	addi	a1,a1,-68 # 20000010 <_ebss>

0001005c <clear_bss_loop>:
   1005c:	00b55863          	bge	a0,a1,1006c <clear_bss_done>
   10060:	00052023          	sw	zero,0(a0)
   10064:	00450513          	addi	a0,a0,4
   10068:	ff5ff06f          	j	1005c <clear_bss_loop>

0001006c <clear_bss_done>:
   1006c:	00001297          	auipc	t0,0x1
   10070:	9e428293          	addi	t0,t0,-1564 # 10a50 <trap_entry>
   10074:	30529073          	csrw	mtvec,t0
   10078:	008000ef          	jal	ra,10080 <main>

0001007c <hang>:
   1007c:	0000006f          	j	1007c <hang>

00010080 <main>:
   10080:	fd010113          	addi	sp,sp,-48
   10084:	000117b7          	lui	a5,0x11
   10088:	02112623          	sw	ra,44(sp)
   1008c:	02812423          	sw	s0,40(sp)
   10090:	a5078793          	addi	a5,a5,-1456 # 10a50 <trap_entry>
   10094:	30579073          	csrw	mtvec,a5
   10098:	6f8000ef          	jal	ra,10790 <syscon_init_clocks>
   1009c:	000067b7          	lui	a5,0x6
   100a0:	3007a073          	csrs	mstatus,a5
   100a4:	00000513          	li	a0,0
   100a8:	570000ef          	jal	ra,10618 <plic_set_threshold>
   100ac:	20000437          	lui	s0,0x20000
   100b0:	0001c637          	lui	a2,0x1c
   100b4:	05f5e5b7          	lui	a1,0x5f5e
   100b8:	400007b7          	lui	a5,0x40000
   100bc:	20060613          	addi	a2,a2,512 # 1c200 <_etext+0xb6f4>
   100c0:	00040513          	mv	a0,s0
   100c4:	10058593          	addi	a1,a1,256 # 5f5e100 <_etext+0x5f4d5f4>
   100c8:	00f42023          	sw	a5,0(s0) # 20000000 <huart0>
   100cc:	77c000ef          	jal	ra,10848 <HAL_UART_Init>
   100d0:	00700593          	li	a1,7
   100d4:	00100513          	li	a0,1
   100d8:	4ec000ef          	jal	ra,105c4 <plic_set_priority>
   100dc:	00100513          	li	a0,1
   100e0:	4fc000ef          	jal	ra,105dc <plic_enable_interrupt>
   100e4:	000117b7          	lui	a5,0x11
   100e8:	af078793          	addi	a5,a5,-1296 # 10af0 <trap_entry+0xa0>
   100ec:	0007ae03          	lw	t3,0(a5)
   100f0:	0047a303          	lw	t1,4(a5)
   100f4:	0087a883          	lw	a7,8(a5)
   100f8:	00c7a803          	lw	a6,12(a5)
   100fc:	0107a683          	lw	a3,16(a5)
   10100:	0147a703          	lw	a4,20(a5)
   10104:	0187c783          	lbu	a5,24(a5)
   10108:	00040513          	mv	a0,s0
   1010c:	00410593          	addi	a1,sp,4
   10110:	01800613          	li	a2,24
   10114:	00f10e23          	sb	a5,28(sp)
   10118:	01c12223          	sw	t3,4(sp)
   1011c:	00612423          	sw	t1,8(sp)
   10120:	01112623          	sw	a7,12(sp)
   10124:	01012823          	sw	a6,16(sp)
   10128:	00d12a23          	sw	a3,20(sp)
   1012c:	00e12c23          	sw	a4,24(sp)
   10130:	758000ef          	jal	ra,10888 <HAL_UART_Transmit>
   10134:	000017b7          	lui	a5,0x1
   10138:	80078793          	addi	a5,a5,-2048 # 800 <_start-0xf800>
   1013c:	3047a073          	csrs	mie,a5
   10140:	00800793          	li	a5,8
   10144:	3007a073          	csrs	mstatus,a5
   10148:	10500073          	wfi
   1014c:	10500073          	wfi
   10150:	ff9ff06f          	j	10148 <main+0xc8>

00010154 <clint_init>:
   10154:	020047b7          	lui	a5,0x2004
   10158:	fff00713          	li	a4,-1
   1015c:	00e7a223          	sw	a4,4(a5) # 2004004 <_etext+0x1ff34f8>
   10160:	020047b7          	lui	a5,0x2004
   10164:	00e7a023          	sw	a4,0(a5) # 2004000 <_etext+0x1ff34f4>
   10168:	020007b7          	lui	a5,0x2000
   1016c:	0007a023          	sw	zero,0(a5) # 2000000 <_etext+0x1fef4f4>
   10170:	00008067          	ret

00010174 <clint_get_mtime>:
   10174:	0200c7b7          	lui	a5,0x200c
   10178:	00078693          	mv	a3,a5
   1017c:	ff868693          	addi	a3,a3,-8
   10180:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x1ffb4f0>
   10184:	0007a703          	lw	a4,0(a5)
   10188:	0006a503          	lw	a0,0(a3)
   1018c:	0007a583          	lw	a1,0(a5)
   10190:	fee59ae3          	bne	a1,a4,10184 <clint_get_mtime+0x10>
   10194:	00008067          	ret

00010198 <clint_set_timer_ms>:
   10198:	0200c7b7          	lui	a5,0x200c
   1019c:	00078813          	mv	a6,a5
   101a0:	ff880813          	addi	a6,a6,-8
   101a4:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x1ffb4f0>
   101a8:	0007a703          	lw	a4,0(a5)
   101ac:	00082603          	lw	a2,0(a6)
   101b0:	0007a683          	lw	a3,0(a5)
   101b4:	fed71ae3          	bne	a4,a3,101a8 <clint_set_timer_ms+0x10>
   101b8:	106257b7          	lui	a5,0x10625
   101bc:	dd378793          	addi	a5,a5,-557 # 10624dd3 <_etext+0x106142c7>
   101c0:	02f5b7b3          	mulhu	a5,a1,a5
   101c4:	fff00693          	li	a3,-1
   101c8:	020045b7          	lui	a1,0x2004
   101cc:	00d5a223          	sw	a3,4(a1) # 2004004 <_etext+0x1ff34f8>
   101d0:	0067d793          	srli	a5,a5,0x6
   101d4:	02a786b3          	mul	a3,a5,a0
   101d8:	02a7b7b3          	mulhu	a5,a5,a0
   101dc:	00c68633          	add	a2,a3,a2
   101e0:	00d636b3          	sltu	a3,a2,a3
   101e4:	00c5a023          	sw	a2,0(a1)
   101e8:	00e787b3          	add	a5,a5,a4
   101ec:	00f686b3          	add	a3,a3,a5
   101f0:	00d5a223          	sw	a3,4(a1)
   101f4:	00008067          	ret

000101f8 <clint_trigger_soft_irq>:
   101f8:	020007b7          	lui	a5,0x2000
   101fc:	00100713          	li	a4,1
   10200:	00e7a023          	sw	a4,0(a5) # 2000000 <_etext+0x1fef4f4>
   10204:	00008067          	ret

00010208 <clint_clear_soft_irq>:
   10208:	020007b7          	lui	a5,0x2000
   1020c:	0007a023          	sw	zero,0(a5) # 2000000 <_etext+0x1fef4f4>
   10210:	00008067          	ret

00010214 <HAL_Delay>:
   10214:	0200c7b7          	lui	a5,0x200c
   10218:	00078693          	mv	a3,a5
   1021c:	ff868693          	addi	a3,a3,-8
   10220:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x1ffb4f0>
   10224:	0007a803          	lw	a6,0(a5)
   10228:	0006a883          	lw	a7,0(a3)
   1022c:	0007a703          	lw	a4,0(a5)
   10230:	fee81ae3          	bne	a6,a4,10224 <HAL_Delay+0x10>
   10234:	106257b7          	lui	a5,0x10625
   10238:	dd378793          	addi	a5,a5,-557 # 10624dd3 <_etext+0x106142c7>
   1023c:	02f5b7b3          	mulhu	a5,a1,a5
   10240:	0200c737          	lui	a4,0x200c
   10244:	00070593          	mv	a1,a4
   10248:	ff858593          	addi	a1,a1,-8
   1024c:	ffc70713          	addi	a4,a4,-4 # 200bffc <_etext+0x1ffb4f0>
   10250:	0067d793          	srli	a5,a5,0x6
   10254:	02a78333          	mul	t1,a5,a0
   10258:	02a7b533          	mulhu	a0,a5,a0
   1025c:	00072783          	lw	a5,0(a4)
   10260:	0005a603          	lw	a2,0(a1)
   10264:	00072683          	lw	a3,0(a4)
   10268:	fed79ae3          	bne	a5,a3,1025c <HAL_Delay+0x48>
   1026c:	411606b3          	sub	a3,a2,a7
   10270:	410787b3          	sub	a5,a5,a6
   10274:	00d63633          	sltu	a2,a2,a3
   10278:	40c787b3          	sub	a5,a5,a2
   1027c:	00a7f663          	bgeu	a5,a0,10288 <HAL_Delay+0x74>
   10280:	00000013          	nop
   10284:	fd9ff06f          	j	1025c <HAL_Delay+0x48>
   10288:	00f51463          	bne	a0,a5,10290 <HAL_Delay+0x7c>
   1028c:	fe66eae3          	bltu	a3,t1,10280 <HAL_Delay+0x6c>
   10290:	00008067          	ret

00010294 <HAL_DMA_Init>:
   10294:	4000a7b7          	lui	a5,0x4000a
   10298:	00100713          	li	a4,1
   1029c:	f0e7a023          	sw	a4,-256(a5) # 40009f00 <_estack+0x1ffe9f00>
   102a0:	00008067          	ret

000102a4 <HAL_DMA_Config>:
   102a4:	04050263          	beqz	a0,102e8 <HAL_DMA_Config+0x44>
   102a8:	00b52023          	sw	a1,0(a0)
   102ac:	00c52223          	sw	a2,4(a0)
   102b0:	00d52423          	sw	a3,8(a0)
   102b4:	04000613          	li	a2,64
   102b8:	0ff87693          	andi	a3,a6,255
   102bc:	03066863          	bltu	a2,a6,102ec <HAL_DMA_Config+0x48>
   102c0:	00169693          	slli	a3,a3,0x1
   102c4:	00070463          	beqz	a4,102cc <HAL_DMA_Config+0x28>
   102c8:	1006e693          	ori	a3,a3,256
   102cc:	00078463          	beqz	a5,102d4 <HAL_DMA_Config+0x30>
   102d0:	2006e693          	ori	a3,a3,512
   102d4:	00a89893          	slli	a7,a7,0xa
   102d8:	00d8e8b3          	or	a7,a7,a3
   102dc:	01152623          	sw	a7,12(a0)
   102e0:	00300793          	li	a5,3
   102e4:	00f52a23          	sw	a5,20(a0)
   102e8:	00008067          	ret
   102ec:	0ff67693          	andi	a3,a2,255
   102f0:	00169693          	slli	a3,a3,0x1
   102f4:	fc070ce3          	beqz	a4,102cc <HAL_DMA_Config+0x28>
   102f8:	fd1ff06f          	j	102c8 <HAL_DMA_Config+0x24>

000102fc <HAL_DMA_Start>:
   102fc:	00050863          	beqz	a0,1030c <HAL_DMA_Start+0x10>
   10300:	00c52783          	lw	a5,12(a0)
   10304:	0017e793          	ori	a5,a5,1
   10308:	00f52623          	sw	a5,12(a0)
   1030c:	00008067          	ret

00010310 <HAL_DMA_Wait_Done>:
   10310:	00050c63          	beqz	a0,10328 <HAL_DMA_Wait_Done+0x18>
   10314:	01052783          	lw	a5,16(a0)
   10318:	0027f793          	andi	a5,a5,2
   1031c:	fe078ce3          	beqz	a5,10314 <HAL_DMA_Wait_Done+0x4>
   10320:	00100793          	li	a5,1
   10324:	00f52c23          	sw	a5,24(a0)
   10328:	00008067          	ret

0001032c <HAL_DMA_TransferCompleteCallback>:
   1032c:	00008067          	ret

00010330 <HAL_DMA_IRQHandler>:
   10330:	04050a63          	beqz	a0,10384 <HAL_DMA_IRQHandler+0x54>
   10334:	01852783          	lw	a5,24(a0)
   10338:	ff010113          	addi	sp,sp,-16
   1033c:	00812423          	sw	s0,8(sp)
   10340:	00112623          	sw	ra,12(sp)
   10344:	0017f793          	andi	a5,a5,1
   10348:	00050413          	mv	s0,a0
   1034c:	02079463          	bnez	a5,10374 <HAL_DMA_IRQHandler+0x44>
   10350:	01842783          	lw	a5,24(s0)
   10354:	0027f793          	andi	a5,a5,2
   10358:	00078663          	beqz	a5,10364 <HAL_DMA_IRQHandler+0x34>
   1035c:	00200793          	li	a5,2
   10360:	00f42c23          	sw	a5,24(s0)
   10364:	00c12083          	lw	ra,12(sp)
   10368:	00812403          	lw	s0,8(sp)
   1036c:	01010113          	addi	sp,sp,16
   10370:	00008067          	ret
   10374:	00100793          	li	a5,1
   10378:	00f52c23          	sw	a5,24(a0)
   1037c:	fb1ff0ef          	jal	ra,1032c <HAL_DMA_TransferCompleteCallback>
   10380:	fd1ff06f          	j	10350 <HAL_DMA_IRQHandler+0x20>
   10384:	00008067          	ret

00010388 <HAL_GPIO_Init>:
   10388:	08050063          	beqz	a0,10408 <HAL_GPIO_Init+0x80>
   1038c:	06058e63          	beqz	a1,10408 <HAL_GPIO_Init+0x80>
   10390:	0005a883          	lw	a7,0(a1)
   10394:	00000793          	li	a5,0
   10398:	00100613          	li	a2,1
   1039c:	00200e13          	li	t3,2
   103a0:	02000813          	li	a6,32
   103a4:	02c0006f          	j	103d0 <HAL_GPIO_Init+0x48>
   103a8:	fff74313          	not	t1,a4
   103ac:	06069063          	bnez	a3,1040c <HAL_GPIO_Init+0x84>
   103b0:	00852703          	lw	a4,8(a0)
   103b4:	00677733          	and	a4,a4,t1
   103b8:	00e52423          	sw	a4,8(a0)
   103bc:	00c52703          	lw	a4,12(a0)
   103c0:	00e37333          	and	t1,t1,a4
   103c4:	00652623          	sw	t1,12(a0)
   103c8:	00178793          	addi	a5,a5,1
   103cc:	03078e63          	beq	a5,a6,10408 <HAL_GPIO_Init+0x80>
   103d0:	00f61733          	sll	a4,a2,a5
   103d4:	011776b3          	and	a3,a4,a7
   103d8:	fe0688e3          	beqz	a3,103c8 <HAL_GPIO_Init+0x40>
   103dc:	0045a683          	lw	a3,4(a1)
   103e0:	fcc694e3          	bne	a3,a2,103a8 <HAL_GPIO_Init+0x20>
   103e4:	00852303          	lw	t1,8(a0)
   103e8:	fff74693          	not	a3,a4
   103ec:	00178793          	addi	a5,a5,1
   103f0:	00e36733          	or	a4,t1,a4
   103f4:	00e52423          	sw	a4,8(a0)
   103f8:	00c52703          	lw	a4,12(a0)
   103fc:	00e6f733          	and	a4,a3,a4
   10400:	00e52623          	sw	a4,12(a0)
   10404:	fd0796e3          	bne	a5,a6,103d0 <HAL_GPIO_Init+0x48>
   10408:	00008067          	ret
   1040c:	fbc69ee3          	bne	a3,t3,103c8 <HAL_GPIO_Init+0x40>
   10410:	00852303          	lw	t1,8(a0)
   10414:	fff74693          	not	a3,a4
   10418:	0066f6b3          	and	a3,a3,t1
   1041c:	00d52423          	sw	a3,8(a0)
   10420:	00c52683          	lw	a3,12(a0)
   10424:	00e6e733          	or	a4,a3,a4
   10428:	00e52623          	sw	a4,12(a0)
   1042c:	f9dff06f          	j	103c8 <HAL_GPIO_Init+0x40>

00010430 <HAL_GPIO_WritePin>:
   10430:	00050e63          	beqz	a0,1044c <HAL_GPIO_WritePin+0x1c>
   10434:	00100793          	li	a5,1
   10438:	00f60c63          	beq	a2,a5,10450 <HAL_GPIO_WritePin+0x20>
   1043c:	00452783          	lw	a5,4(a0)
   10440:	fff5c593          	not	a1,a1
   10444:	00f5f5b3          	and	a1,a1,a5
   10448:	00b52223          	sw	a1,4(a0)
   1044c:	00008067          	ret
   10450:	00452783          	lw	a5,4(a0)
   10454:	00f5e5b3          	or	a1,a1,a5
   10458:	00b52223          	sw	a1,4(a0)
   1045c:	00008067          	ret

00010460 <HAL_GPIO_TogglePin>:
   10460:	00050863          	beqz	a0,10470 <HAL_GPIO_TogglePin+0x10>
   10464:	00452783          	lw	a5,4(a0)
   10468:	00f5c5b3          	xor	a1,a1,a5
   1046c:	00b52223          	sw	a1,4(a0)
   10470:	00008067          	ret

00010474 <HAL_GPIO_ReadPin>:
   10474:	00050a63          	beqz	a0,10488 <HAL_GPIO_ReadPin+0x14>
   10478:	00052783          	lw	a5,0(a0)
   1047c:	00f5f5b3          	and	a1,a1,a5
   10480:	00b03533          	snez	a0,a1
   10484:	00008067          	ret
   10488:	00000513          	li	a0,0
   1048c:	00008067          	ret

00010490 <HAL_GPIO_EXTI_Callback>:
   10490:	00008067          	ret

00010494 <HAL_GPIO_IRQHandler>:
   10494:	08050663          	beqz	a0,10520 <HAL_GPIO_IRQHandler+0x8c>
   10498:	fe010113          	addi	sp,sp,-32
   1049c:	01052783          	lw	a5,16(a0)
   104a0:	00912a23          	sw	s1,20(sp)
   104a4:	00c52483          	lw	s1,12(a0)
   104a8:	00812c23          	sw	s0,24(sp)
   104ac:	01212823          	sw	s2,16(sp)
   104b0:	01312623          	sw	s3,12(sp)
   104b4:	01412423          	sw	s4,8(sp)
   104b8:	00112e23          	sw	ra,28(sp)
   104bc:	00050a13          	mv	s4,a0
   104c0:	00000413          	li	s0,0
   104c4:	00100993          	li	s3,1
   104c8:	00f4f4b3          	and	s1,s1,a5
   104cc:	02000913          	li	s2,32
   104d0:	00c0006f          	j	104dc <HAL_GPIO_IRQHandler+0x48>
   104d4:	00140413          	addi	s0,s0,1
   104d8:	03240463          	beq	s0,s2,10500 <HAL_GPIO_IRQHandler+0x6c>
   104dc:	008997b3          	sll	a5,s3,s0
   104e0:	00f4f733          	and	a4,s1,a5
   104e4:	fe0708e3          	beqz	a4,104d4 <HAL_GPIO_IRQHandler+0x40>
   104e8:	01079513          	slli	a0,a5,0x10
   104ec:	01055513          	srli	a0,a0,0x10
   104f0:	00fa2823          	sw	a5,16(s4)
   104f4:	00140413          	addi	s0,s0,1
   104f8:	f99ff0ef          	jal	ra,10490 <HAL_GPIO_EXTI_Callback>
   104fc:	ff2410e3          	bne	s0,s2,104dc <HAL_GPIO_IRQHandler+0x48>
   10500:	01c12083          	lw	ra,28(sp)
   10504:	01812403          	lw	s0,24(sp)
   10508:	01412483          	lw	s1,20(sp)
   1050c:	01012903          	lw	s2,16(sp)
   10510:	00c12983          	lw	s3,12(sp)
   10514:	00812a03          	lw	s4,8(sp)
   10518:	02010113          	addi	sp,sp,32
   1051c:	00008067          	ret
   10520:	00008067          	ret

00010524 <i2c_init>:
   10524:	400047b7          	lui	a5,0x40004
   10528:	00a7a023          	sw	a0,0(a5) # 40004000 <_estack+0x1ffe4000>
   1052c:	00008067          	ret

00010530 <i2c_start>:
   10530:	40004737          	lui	a4,0x40004
   10534:	08000793          	li	a5,128
   10538:	00f72623          	sw	a5,12(a4) # 4000400c <_estack+0x1ffe400c>
   1053c:	01072783          	lw	a5,16(a4)
   10540:	0027f793          	andi	a5,a5,2
   10544:	fe079ce3          	bnez	a5,1053c <i2c_start+0xc>
   10548:	00008067          	ret

0001054c <i2c_stop>:
   1054c:	40004737          	lui	a4,0x40004
   10550:	04000793          	li	a5,64
   10554:	00f72623          	sw	a5,12(a4) # 4000400c <_estack+0x1ffe400c>
   10558:	01072783          	lw	a5,16(a4)
   1055c:	0027f793          	andi	a5,a5,2
   10560:	fe079ce3          	bnez	a5,10558 <i2c_stop+0xc>
   10564:	00008067          	ret

00010568 <i2c_write>:
   10568:	40004737          	lui	a4,0x40004
   1056c:	00a72223          	sw	a0,4(a4) # 40004004 <_estack+0x1ffe4004>
   10570:	01000793          	li	a5,16
   10574:	00f72623          	sw	a5,12(a4)
   10578:	01072783          	lw	a5,16(a4)
   1057c:	0027f793          	andi	a5,a5,2
   10580:	fe079ce3          	bnez	a5,10578 <i2c_write+0x10>
   10584:	01072503          	lw	a0,16(a4)
   10588:	00755513          	srli	a0,a0,0x7
   1058c:	00157513          	andi	a0,a0,1
   10590:	00008067          	ret

00010594 <i2c_read>:
   10594:	00a03533          	snez	a0,a0
   10598:	00351513          	slli	a0,a0,0x3
   1059c:	02050513          	addi	a0,a0,32
   105a0:	40004737          	lui	a4,0x40004
   105a4:	00a72623          	sw	a0,12(a4) # 4000400c <_estack+0x1ffe400c>
   105a8:	01072783          	lw	a5,16(a4)
   105ac:	0027f793          	andi	a5,a5,2
   105b0:	fe079ce3          	bnez	a5,105a8 <i2c_read+0x14>
   105b4:	00872503          	lw	a0,8(a4)
   105b8:	0ff57513          	andi	a0,a0,255
   105bc:	00008067          	ret

000105c0 <HAL_UART_RxCallback>:
   105c0:	00008067          	ret

000105c4 <plic_set_priority>:
   105c4:	100027b7          	lui	a5,0x10002
   105c8:	00f50533          	add	a0,a0,a5
   105cc:	0075f593          	andi	a1,a1,7
   105d0:	00251513          	slli	a0,a0,0x2
   105d4:	00b52023          	sw	a1,0(a0)
   105d8:	00008067          	ret

000105dc <plic_enable_interrupt>:
   105dc:	4000a737          	lui	a4,0x4000a
   105e0:	00072683          	lw	a3,0(a4) # 4000a000 <_estack+0x1ffea000>
   105e4:	00100793          	li	a5,1
   105e8:	00a797b3          	sll	a5,a5,a0
   105ec:	00d7e7b3          	or	a5,a5,a3
   105f0:	00f72023          	sw	a5,0(a4)
   105f4:	00008067          	ret

000105f8 <plic_disable_interrupt>:
   105f8:	4000a737          	lui	a4,0x4000a
   105fc:	00072683          	lw	a3,0(a4) # 4000a000 <_estack+0x1ffea000>
   10600:	00100793          	li	a5,1
   10604:	00a797b3          	sll	a5,a5,a0
   10608:	fff7c793          	not	a5,a5
   1060c:	00d7f7b3          	and	a5,a5,a3
   10610:	00f72023          	sw	a5,0(a4)
   10614:	00008067          	ret

00010618 <plic_set_threshold>:
   10618:	00757513          	andi	a0,a0,7
   1061c:	4000c7b7          	lui	a5,0x4000c
   10620:	00a7a023          	sw	a0,0(a5) # 4000c000 <_estack+0x1ffec000>
   10624:	00008067          	ret

00010628 <plic_claim>:
   10628:	4000c7b7          	lui	a5,0x4000c
   1062c:	0047a503          	lw	a0,4(a5) # 4000c004 <_estack+0x1ffec004>
   10630:	00008067          	ret

00010634 <plic_complete>:
   10634:	00050663          	beqz	a0,10640 <plic_complete+0xc>
   10638:	4000c7b7          	lui	a5,0x4000c
   1063c:	00a7a223          	sw	a0,4(a5) # 4000c004 <_estack+0x1ffec004>
   10640:	00008067          	ret

00010644 <spi_init>:
   10644:	00151513          	slli	a0,a0,0x1
   10648:	00257513          	andi	a0,a0,2
   1064c:	0015f593          	andi	a1,a1,1
   10650:	400037b7          	lui	a5,0x40003
   10654:	00b56533          	or	a0,a0,a1
   10658:	00a7a023          	sw	a0,0(a5) # 40003000 <_estack+0x1ffe3000>
   1065c:	00c7a423          	sw	a2,8(a5)
   10660:	00100713          	li	a4,1
   10664:	00e7a223          	sw	a4,4(a5)
   10668:	00008067          	ret

0001066c <spi_set_cs>:
   1066c:	00157513          	andi	a0,a0,1
   10670:	400037b7          	lui	a5,0x40003
   10674:	00a7a223          	sw	a0,4(a5) # 40003004 <_estack+0x1ffe3004>
   10678:	00008067          	ret

0001067c <spi_transfer>:
   1067c:	40003737          	lui	a4,0x40003
   10680:	01472783          	lw	a5,20(a4) # 40003014 <_estack+0x1ffe3014>
   10684:	0017f793          	andi	a5,a5,1
   10688:	fe079ce3          	bnez	a5,10680 <spi_transfer+0x4>
   1068c:	00a72623          	sw	a0,12(a4)
   10690:	40003737          	lui	a4,0x40003
   10694:	01472783          	lw	a5,20(a4) # 40003014 <_estack+0x1ffe3014>
   10698:	0027f793          	andi	a5,a5,2
   1069c:	fe078ce3          	beqz	a5,10694 <spi_transfer+0x18>
   106a0:	01072503          	lw	a0,16(a4)
   106a4:	0ff57513          	andi	a0,a0,255
   106a8:	00008067          	ret

000106ac <_sbrk>:
   106ac:	20000737          	lui	a4,0x20000
   106b0:	00872783          	lw	a5,8(a4) # 20000008 <heap_end.0>
   106b4:	00078a63          	beqz	a5,106c8 <_sbrk+0x1c>
   106b8:	00a78533          	add	a0,a5,a0
   106bc:	00a72423          	sw	a0,8(a4)
   106c0:	00078513          	mv	a0,a5
   106c4:	00008067          	ret
   106c8:	200007b7          	lui	a5,0x20000
   106cc:	01078793          	addi	a5,a5,16 # 20000010 <_ebss>
   106d0:	00a78533          	add	a0,a5,a0
   106d4:	00a72423          	sw	a0,8(a4)
   106d8:	00078513          	mv	a0,a5
   106dc:	00008067          	ret

000106e0 <_write>:
   106e0:	ff010113          	addi	sp,sp,-16
   106e4:	00812423          	sw	s0,8(sp)
   106e8:	20000537          	lui	a0,0x20000
   106ec:	00060413          	mv	s0,a2
   106f0:	01061613          	slli	a2,a2,0x10
   106f4:	00050513          	mv	a0,a0
   106f8:	01065613          	srli	a2,a2,0x10
   106fc:	00112623          	sw	ra,12(sp)
   10700:	188000ef          	jal	ra,10888 <HAL_UART_Transmit>
   10704:	00c12083          	lw	ra,12(sp)
   10708:	00040513          	mv	a0,s0
   1070c:	00812403          	lw	s0,8(sp)
   10710:	01010113          	addi	sp,sp,16
   10714:	00008067          	ret

00010718 <_close>:
   10718:	fff00513          	li	a0,-1
   1071c:	00008067          	ret

00010720 <_fstat>:
   10720:	00000513          	li	a0,0
   10724:	00008067          	ret

00010728 <_isatty>:
   10728:	00100513          	li	a0,1
   1072c:	00008067          	ret

00010730 <_lseek>:
   10730:	00000513          	li	a0,0
   10734:	00008067          	ret

00010738 <_read>:
   10738:	00000513          	li	a0,0
   1073c:	00008067          	ret

00010740 <syscon_enable_clock>:
   10740:	40007737          	lui	a4,0x40007
   10744:	00472683          	lw	a3,4(a4) # 40007004 <_estack+0x1ffe7004>
   10748:	00100793          	li	a5,1
   1074c:	00a797b3          	sll	a5,a5,a0
   10750:	00d7e7b3          	or	a5,a5,a3
   10754:	00f72223          	sw	a5,4(a4)
   10758:	00008067          	ret

0001075c <syscon_disable_clock>:
   1075c:	00700793          	li	a5,7
   10760:	02a7e063          	bltu	a5,a0,10780 <syscon_disable_clock+0x24>
   10764:	40007737          	lui	a4,0x40007
   10768:	00472683          	lw	a3,4(a4) # 40007004 <_estack+0x1ffe7004>
   1076c:	00100793          	li	a5,1
   10770:	00a797b3          	sll	a5,a5,a0
   10774:	fff7c793          	not	a5,a5
   10778:	00d7f7b3          	and	a5,a5,a3
   1077c:	00f72223          	sw	a5,4(a4)
   10780:	00008067          	ret

00010784 <syscon_set_boot_address>:
   10784:	400077b7          	lui	a5,0x40007
   10788:	00a7a023          	sw	a0,0(a5) # 40007000 <_estack+0x1ffe7000>
   1078c:	00008067          	ret

00010790 <syscon_init_clocks>:
   10790:	400077b7          	lui	a5,0x40007
   10794:	04e00713          	li	a4,78
   10798:	00e7a223          	sw	a4,4(a5) # 40007004 <_estack+0x1ffe7004>
   1079c:	00008067          	ret

000107a0 <system_trap_handler>:
   107a0:	800007b7          	lui	a5,0x80000
   107a4:	00b78793          	addi	a5,a5,11 # 8000000b <_estack+0x5ffe000b>
   107a8:	02f50463          	beq	a0,a5,107d0 <system_trap_handler+0x30>
   107ac:	800007b7          	lui	a5,0x80000
   107b0:	00778793          	addi	a5,a5,7 # 80000007 <_estack+0x5ffe0007>
   107b4:	04f50c63          	beq	a0,a5,1080c <system_trap_handler+0x6c>
   107b8:	800007b7          	lui	a5,0x80000
   107bc:	00378793          	addi	a5,a5,3 # 80000003 <_estack+0x5ffe0003>
   107c0:	04f50463          	beq	a0,a5,10808 <system_trap_handler+0x68>
   107c4:	10500073          	wfi
   107c8:	10500073          	wfi
   107cc:	ff9ff06f          	j	107c4 <system_trap_handler+0x24>
   107d0:	ff010113          	addi	sp,sp,-16
   107d4:	00812423          	sw	s0,8(sp)
   107d8:	00112623          	sw	ra,12(sp)
   107dc:	e4dff0ef          	jal	ra,10628 <plic_claim>
   107e0:	00100793          	li	a5,1
   107e4:	00050413          	mv	s0,a0
   107e8:	02f50a63          	beq	a0,a5,1081c <system_trap_handler+0x7c>
   107ec:	00200793          	li	a5,2
   107f0:	04f50663          	beq	a0,a5,1083c <system_trap_handler+0x9c>
   107f4:	02051a63          	bnez	a0,10828 <system_trap_handler+0x88>
   107f8:	00c12083          	lw	ra,12(sp)
   107fc:	00812403          	lw	s0,8(sp)
   10800:	01010113          	addi	sp,sp,16
   10804:	00008067          	ret
   10808:	a01ff06f          	j	10208 <clint_clear_soft_irq>
   1080c:	0bebc5b7          	lui	a1,0xbebc
   10810:	20058593          	addi	a1,a1,512 # bebc200 <_etext+0xbeab6f4>
   10814:	3e800513          	li	a0,1000
   10818:	981ff06f          	j	10198 <clint_set_timer_ms>
   1081c:	20000537          	lui	a0,0x20000
   10820:	00050513          	mv	a0,a0
   10824:	1e0000ef          	jal	ra,10a04 <HAL_UART_IRQHandler>
   10828:	00040513          	mv	a0,s0
   1082c:	00812403          	lw	s0,8(sp)
   10830:	00c12083          	lw	ra,12(sp)
   10834:	01010113          	addi	sp,sp,16
   10838:	dfdff06f          	j	10634 <plic_complete>
   1083c:	40001537          	lui	a0,0x40001
   10840:	c55ff0ef          	jal	ra,10494 <HAL_GPIO_IRQHandler>
   10844:	fe5ff06f          	j	10828 <system_trap_handler+0x88>

00010848 <HAL_UART_Init>:
   10848:	02050e63          	beqz	a0,10884 <HAL_UART_Init+0x3c>
   1084c:	00052783          	lw	a5,0(a0) # 40001000 <_estack+0x1ffe1000>
   10850:	02078a63          	beqz	a5,10884 <HAL_UART_Init+0x3c>
   10854:	02c5d733          	divu	a4,a1,a2
   10858:	00461613          	slli	a2,a2,0x4
   1085c:	00200813          	li	a6,2
   10860:	00100693          	li	a3,1
   10864:	02c5d5b3          	divu	a1,a1,a2
   10868:	01071713          	slli	a4,a4,0x10
   1086c:	01075713          	srli	a4,a4,0x10
   10870:	01059593          	slli	a1,a1,0x10
   10874:	00e5e5b3          	or	a1,a1,a4
   10878:	00b7a023          	sw	a1,0(a5)
   1087c:	0107a823          	sw	a6,16(a5)
   10880:	00d52223          	sw	a3,4(a0)
   10884:	00008067          	ret

00010888 <HAL_UART_Transmit>:
   10888:	00452703          	lw	a4,4(a0)
   1088c:	00100793          	li	a5,1
   10890:	04f71663          	bne	a4,a5,108dc <HAL_UART_Transmit+0x54>
   10894:	04058463          	beqz	a1,108dc <HAL_UART_Transmit+0x54>
   10898:	04060263          	beqz	a2,108dc <HAL_UART_Transmit+0x54>
   1089c:	00052703          	lw	a4,0(a0)
   108a0:	00300793          	li	a5,3
   108a4:	00c586b3          	add	a3,a1,a2
   108a8:	00f52223          	sw	a5,4(a0)
   108ac:	00c72783          	lw	a5,12(a4)
   108b0:	0047f793          	andi	a5,a5,4
   108b4:	fe079ce3          	bnez	a5,108ac <HAL_UART_Transmit+0x24>
   108b8:	0005c783          	lbu	a5,0(a1)
   108bc:	00158593          	addi	a1,a1,1
   108c0:	00f72223          	sw	a5,4(a4)
   108c4:	fed594e3          	bne	a1,a3,108ac <HAL_UART_Transmit+0x24>
   108c8:	00c72783          	lw	a5,12(a4)
   108cc:	0107f793          	andi	a5,a5,16
   108d0:	fe079ce3          	bnez	a5,108c8 <HAL_UART_Transmit+0x40>
   108d4:	00100793          	li	a5,1
   108d8:	00f52223          	sw	a5,4(a0)
   108dc:	00008067          	ret

000108e0 <HAL_UART_Transmit_DMA>:
   108e0:	00452803          	lw	a6,4(a0)
   108e4:	ff010113          	addi	sp,sp,-16
   108e8:	00812423          	sw	s0,8(sp)
   108ec:	00112623          	sw	ra,12(sp)
   108f0:	00050413          	mv	s0,a0
   108f4:	00100513          	li	a0,1
   108f8:	04a81e63          	bne	a6,a0,10954 <HAL_UART_Transmit_DMA+0x74>
   108fc:	04060c63          	beqz	a2,10954 <HAL_UART_Transmit_DMA+0x74>
   10900:	04068a63          	beqz	a3,10954 <HAL_UART_Transmit_DMA+0x74>
   10904:	00912223          	sw	s1,4(sp)
   10908:	00058493          	mv	s1,a1
   1090c:	04058c63          	beqz	a1,10964 <HAL_UART_Transmit_DMA+0x84>
   10910:	00042503          	lw	a0,0(s0)
   10914:	00300793          	li	a5,3
   10918:	00070893          	mv	a7,a4
   1091c:	00060593          	mv	a1,a2
   10920:	00080713          	mv	a4,a6
   10924:	00450613          	addi	a2,a0,4
   10928:	00f42223          	sw	a5,4(s0)
   1092c:	00048513          	mv	a0,s1
   10930:	00000793          	li	a5,0
   10934:	971ff0ef          	jal	ra,102a4 <HAL_DMA_Config>
   10938:	00048513          	mv	a0,s1
   1093c:	9c1ff0ef          	jal	ra,102fc <HAL_DMA_Start>
   10940:	00042703          	lw	a4,0(s0)
   10944:	00412483          	lw	s1,4(sp)
   10948:	01072783          	lw	a5,16(a4)
   1094c:	0047e793          	ori	a5,a5,4
   10950:	00f72823          	sw	a5,16(a4)
   10954:	00c12083          	lw	ra,12(sp)
   10958:	00812403          	lw	s0,8(sp)
   1095c:	01010113          	addi	sp,sp,16
   10960:	00008067          	ret
   10964:	00412483          	lw	s1,4(sp)
   10968:	fedff06f          	j	10954 <HAL_UART_Transmit_DMA+0x74>

0001096c <HAL_UART_Receive_DMA>:
   1096c:	00452803          	lw	a6,4(a0)
   10970:	ff010113          	addi	sp,sp,-16
   10974:	00812423          	sw	s0,8(sp)
   10978:	00112623          	sw	ra,12(sp)
   1097c:	00050413          	mv	s0,a0
   10980:	00100513          	li	a0,1
   10984:	04a81c63          	bne	a6,a0,109dc <HAL_UART_Receive_DMA+0x70>
   10988:	04060a63          	beqz	a2,109dc <HAL_UART_Receive_DMA+0x70>
   1098c:	00912223          	sw	s1,4(sp)
   10990:	00058493          	mv	s1,a1
   10994:	04068c63          	beqz	a3,109ec <HAL_UART_Receive_DMA+0x80>
   10998:	04048a63          	beqz	s1,109ec <HAL_UART_Receive_DMA+0x80>
   1099c:	00042583          	lw	a1,0(s0)
   109a0:	00400793          	li	a5,4
   109a4:	00070893          	mv	a7,a4
   109a8:	00048513          	mv	a0,s1
   109ac:	00000713          	li	a4,0
   109b0:	00858593          	addi	a1,a1,8
   109b4:	00f42223          	sw	a5,4(s0)
   109b8:	00080793          	mv	a5,a6
   109bc:	8e9ff0ef          	jal	ra,102a4 <HAL_DMA_Config>
   109c0:	00048513          	mv	a0,s1
   109c4:	939ff0ef          	jal	ra,102fc <HAL_DMA_Start>
   109c8:	00042703          	lw	a4,0(s0)
   109cc:	00412483          	lw	s1,4(sp)
   109d0:	01072783          	lw	a5,16(a4)
   109d4:	0087e793          	ori	a5,a5,8
   109d8:	00f72823          	sw	a5,16(a4)
   109dc:	00c12083          	lw	ra,12(sp)
   109e0:	00812403          	lw	s0,8(sp)
   109e4:	01010113          	addi	sp,sp,16
   109e8:	00008067          	ret
   109ec:	00c12083          	lw	ra,12(sp)
   109f0:	00812403          	lw	s0,8(sp)
   109f4:	00412483          	lw	s1,4(sp)
   109f8:	01010113          	addi	sp,sp,16
   109fc:	00008067          	ret
   10a00:	00008067          	ret

00010a04 <HAL_UART_IRQHandler>:
   10a04:	00052703          	lw	a4,0(a0)
   10a08:	00c72783          	lw	a5,12(a4)
   10a0c:	0087f793          	andi	a5,a5,8
   10a10:	00078463          	beqz	a5,10a18 <HAL_UART_IRQHandler+0x14>
   10a14:	00008067          	ret
   10a18:	00872583          	lw	a1,8(a4)
   10a1c:	0ff5f593          	andi	a1,a1,255
   10a20:	ba1ff06f          	j	105c0 <HAL_UART_RxCallback>

00010a24 <HAL_WDT_Init>:
   10a24:	00050c63          	beqz	a0,10a3c <HAL_WDT_Init+0x18>
   10a28:	00b52023          	sw	a1,0(a0)
   10a2c:	00300793          	li	a5,3
   10a30:	00f52423          	sw	a5,8(a0)
   10a34:	00100793          	li	a5,1
   10a38:	00f52623          	sw	a5,12(a0)
   10a3c:	00008067          	ret

00010a40 <HAL_WDT_Refresh>:
   10a40:	00050663          	beqz	a0,10a4c <HAL_WDT_Refresh+0xc>
   10a44:	00100793          	li	a5,1
   10a48:	00f52623          	sw	a5,12(a0)
   10a4c:	00008067          	ret

00010a50 <trap_entry>:
   10a50:	f8010113          	addi	sp,sp,-128
   10a54:	00112023          	sw	ra,0(sp)
   10a58:	00512223          	sw	t0,4(sp)
   10a5c:	00612423          	sw	t1,8(sp)
   10a60:	00712623          	sw	t2,12(sp)
   10a64:	00a12823          	sw	a0,16(sp)
   10a68:	00b12a23          	sw	a1,20(sp)
   10a6c:	00c12c23          	sw	a2,24(sp)
   10a70:	00d12e23          	sw	a3,28(sp)
   10a74:	02e12023          	sw	a4,32(sp)
   10a78:	02f12223          	sw	a5,36(sp)
   10a7c:	03012423          	sw	a6,40(sp)
   10a80:	03112623          	sw	a7,44(sp)
   10a84:	03c12823          	sw	t3,48(sp)
   10a88:	03d12a23          	sw	t4,52(sp)
   10a8c:	03e12c23          	sw	t5,56(sp)
   10a90:	03f12e23          	sw	t6,60(sp)
   10a94:	34202573          	csrr	a0,mcause
   10a98:	341025f3          	csrr	a1,mepc
   10a9c:	d05ff0ef          	jal	ra,107a0 <system_trap_handler>
   10aa0:	00012083          	lw	ra,0(sp)
   10aa4:	00412283          	lw	t0,4(sp)
   10aa8:	00812303          	lw	t1,8(sp)
   10aac:	00c12383          	lw	t2,12(sp)
   10ab0:	01012503          	lw	a0,16(sp)
   10ab4:	01412583          	lw	a1,20(sp)
   10ab8:	01812603          	lw	a2,24(sp)
   10abc:	01c12683          	lw	a3,28(sp)
   10ac0:	02012703          	lw	a4,32(sp)
   10ac4:	02412783          	lw	a5,36(sp)
   10ac8:	02812803          	lw	a6,40(sp)
   10acc:	02c12883          	lw	a7,44(sp)
   10ad0:	03012e03          	lw	t3,48(sp)
   10ad4:	03412e83          	lw	t4,52(sp)
   10ad8:	03812f03          	lw	t5,56(sp)
   10adc:	03c12f83          	lw	t6,60(sp)
   10ae0:	08010113          	addi	sp,sp,128
   10ae4:	30200073          	mret
	...
   10af0:	4548                	lw	a0,12(a0)
   10af2:	4c4c                	lw	a1,28(s0)
   10af4:	4952204f          	fnmadd.s	ft0,ft4,fs5,fs1,rdn
   10af8:	562d4353          	0x562d4353
   10afc:	5520                	lw	s0,104(a0)
   10afe:	5241                	li	tp,-16
   10b00:	2054                	fld	fa3,128(s0)
   10b02:	4554                	lw	a3,12(a0)
   10b04:	0a215453          	fsub.d	fs0,ft2,ft2,unknown
   10b08:	0000                	unimp
	...
