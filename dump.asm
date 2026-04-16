
my_soc_firmware.elf:     file format elf32-littleriscv


Disassembly of section .text:

00010000 <_start>:
   10000:	30001073          	csrw	mstatus,zero
   10004:	30401073          	csrw	mie,zero
   10008:	000062b7          	lui	t0,0x6
   1000c:	3002a073          	csrs	mstatus,t0
   10010:	00301073          	fscsr	zero
   10014:	80000117          	auipc	sp,0x80000
   10018:	fec10113          	addi	sp,sp,-20 # 80010000 <_estack+0x0>
   1001c:	7fff0517          	auipc	a0,0x7fff0
   10020:	fe450513          	addi	a0,a0,-28 # 80000000 <dst_arr>
   10024:	7fff0597          	auipc	a1,0x7fff0
   10028:	fe458593          	addi	a1,a1,-28 # 80000008 <huart0>
   1002c:	00001617          	auipc	a2,0x1
   10030:	a6460613          	addi	a2,a2,-1436 # 10a90 <_etext>

00010034 <copy_data_loop>:
   10034:	00b55c63          	bge	a0,a1,1004c <copy_data_done>
   10038:	00062283          	lw	t0,0(a2)
   1003c:	00552023          	sw	t0,0(a0)
   10040:	00450513          	addi	a0,a0,4
   10044:	00460613          	addi	a2,a2,4
   10048:	fedff06f          	j	10034 <copy_data_loop>

0001004c <copy_data_done>:
   1004c:	7fff0517          	auipc	a0,0x7fff0
   10050:	fbc50513          	addi	a0,a0,-68 # 80000008 <huart0>
   10054:	7fff0597          	auipc	a1,0x7fff0
   10058:	fc058593          	addi	a1,a1,-64 # 80000014 <_ebss>

0001005c <clear_bss_loop>:
   1005c:	00b55863          	bge	a0,a1,1006c <clear_bss_done>
   10060:	00052023          	sw	zero,0(a0)
   10064:	00450513          	addi	a0,a0,4
   10068:	ff5ff06f          	j	1005c <clear_bss_loop>

0001006c <clear_bss_done>:
   1006c:	00001297          	auipc	t0,0x1
   10070:	85428293          	addi	t0,t0,-1964 # 108c0 <trap_entry>
   10074:	30529073          	csrw	mtvec,t0
   10078:	0e9000ef          	jal	ra,10960 <main>

0001007c <hang>:
   1007c:	0000006f          	j	1007c <hang>

00010080 <clint_init>:
   10080:	020047b7          	lui	a5,0x2004
   10084:	fff00713          	li	a4,-1
   10088:	00e7a223          	sw	a4,4(a5) # 2004004 <_etext+0x1ff3574>
   1008c:	020047b7          	lui	a5,0x2004
   10090:	00e7a023          	sw	a4,0(a5) # 2004000 <_etext+0x1ff3570>
   10094:	020007b7          	lui	a5,0x2000
   10098:	0007a023          	sw	zero,0(a5) # 2000000 <_etext+0x1fef570>
   1009c:	00008067          	ret

000100a0 <clint_get_mtime>:
   100a0:	0200c7b7          	lui	a5,0x200c
   100a4:	00078693          	mv	a3,a5
   100a8:	ff868693          	addi	a3,a3,-8
   100ac:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x1ffb56c>
   100b0:	0007a703          	lw	a4,0(a5)
   100b4:	0006a503          	lw	a0,0(a3)
   100b8:	0007a583          	lw	a1,0(a5)
   100bc:	fee59ae3          	bne	a1,a4,100b0 <clint_get_mtime+0x10>
   100c0:	00008067          	ret

000100c4 <clint_set_timer_ms>:
   100c4:	0200c7b7          	lui	a5,0x200c
   100c8:	00078813          	mv	a6,a5
   100cc:	ff880813          	addi	a6,a6,-8
   100d0:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x1ffb56c>
   100d4:	0007a703          	lw	a4,0(a5)
   100d8:	00082603          	lw	a2,0(a6)
   100dc:	0007a683          	lw	a3,0(a5)
   100e0:	fed71ae3          	bne	a4,a3,100d4 <clint_set_timer_ms+0x10>
   100e4:	106257b7          	lui	a5,0x10625
   100e8:	dd378793          	addi	a5,a5,-557 # 10624dd3 <_etext+0x10614343>
   100ec:	02f5b7b3          	mulhu	a5,a1,a5
   100f0:	fff00693          	li	a3,-1
   100f4:	020045b7          	lui	a1,0x2004
   100f8:	00d5a223          	sw	a3,4(a1) # 2004004 <_etext+0x1ff3574>
   100fc:	0067d793          	srli	a5,a5,0x6
   10100:	02a786b3          	mul	a3,a5,a0
   10104:	02a7b7b3          	mulhu	a5,a5,a0
   10108:	00c68633          	add	a2,a3,a2
   1010c:	00d636b3          	sltu	a3,a2,a3
   10110:	00c5a023          	sw	a2,0(a1)
   10114:	00e787b3          	add	a5,a5,a4
   10118:	00f686b3          	add	a3,a3,a5
   1011c:	00d5a223          	sw	a3,4(a1)
   10120:	00008067          	ret

00010124 <clint_trigger_soft_irq>:
   10124:	020007b7          	lui	a5,0x2000
   10128:	00100713          	li	a4,1
   1012c:	00e7a023          	sw	a4,0(a5) # 2000000 <_etext+0x1fef570>
   10130:	00008067          	ret

00010134 <clint_clear_soft_irq>:
   10134:	020007b7          	lui	a5,0x2000
   10138:	0007a023          	sw	zero,0(a5) # 2000000 <_etext+0x1fef570>
   1013c:	00008067          	ret

00010140 <HAL_Delay>:
   10140:	0200c7b7          	lui	a5,0x200c
   10144:	00078693          	mv	a3,a5
   10148:	ff868693          	addi	a3,a3,-8
   1014c:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x1ffb56c>
   10150:	0007a803          	lw	a6,0(a5)
   10154:	0006a883          	lw	a7,0(a3)
   10158:	0007a703          	lw	a4,0(a5)
   1015c:	fee81ae3          	bne	a6,a4,10150 <HAL_Delay+0x10>
   10160:	106257b7          	lui	a5,0x10625
   10164:	dd378793          	addi	a5,a5,-557 # 10624dd3 <_etext+0x10614343>
   10168:	02f5b7b3          	mulhu	a5,a1,a5
   1016c:	0200c737          	lui	a4,0x200c
   10170:	00070593          	mv	a1,a4
   10174:	ff858593          	addi	a1,a1,-8
   10178:	ffc70713          	addi	a4,a4,-4 # 200bffc <_etext+0x1ffb56c>
   1017c:	0067d793          	srli	a5,a5,0x6
   10180:	02a78333          	mul	t1,a5,a0
   10184:	02a7b533          	mulhu	a0,a5,a0
   10188:	00072783          	lw	a5,0(a4)
   1018c:	0005a603          	lw	a2,0(a1)
   10190:	00072683          	lw	a3,0(a4)
   10194:	fed79ae3          	bne	a5,a3,10188 <HAL_Delay+0x48>
   10198:	411606b3          	sub	a3,a2,a7
   1019c:	410787b3          	sub	a5,a5,a6
   101a0:	00d63633          	sltu	a2,a2,a3
   101a4:	40c787b3          	sub	a5,a5,a2
   101a8:	00a7f663          	bgeu	a5,a0,101b4 <HAL_Delay+0x74>
   101ac:	00000013          	nop
   101b0:	fd9ff06f          	j	10188 <HAL_Delay+0x48>
   101b4:	00f51463          	bne	a0,a5,101bc <HAL_Delay+0x7c>
   101b8:	fe66eae3          	bltu	a3,t1,101ac <HAL_Delay+0x6c>
   101bc:	00008067          	ret

000101c0 <HAL_DMA_Init>:
   101c0:	400097b7          	lui	a5,0x40009
   101c4:	00100713          	li	a4,1
   101c8:	f0e7a023          	sw	a4,-256(a5) # 40008f00 <_etext+0x3fff8470>
   101cc:	00008067          	ret

000101d0 <HAL_DMA_Config>:
   101d0:	04050263          	beqz	a0,10214 <HAL_DMA_Config+0x44>
   101d4:	00b52023          	sw	a1,0(a0)
   101d8:	00c52223          	sw	a2,4(a0)
   101dc:	00d52423          	sw	a3,8(a0)
   101e0:	04000613          	li	a2,64
   101e4:	0ff87693          	andi	a3,a6,255
   101e8:	03066863          	bltu	a2,a6,10218 <HAL_DMA_Config+0x48>
   101ec:	00169693          	slli	a3,a3,0x1
   101f0:	00070463          	beqz	a4,101f8 <HAL_DMA_Config+0x28>
   101f4:	1006e693          	ori	a3,a3,256
   101f8:	00078463          	beqz	a5,10200 <HAL_DMA_Config+0x30>
   101fc:	2006e693          	ori	a3,a3,512
   10200:	00a89893          	slli	a7,a7,0xa
   10204:	00d8e8b3          	or	a7,a7,a3
   10208:	01152623          	sw	a7,12(a0)
   1020c:	00300793          	li	a5,3
   10210:	00f52a23          	sw	a5,20(a0)
   10214:	00008067          	ret
   10218:	0ff67693          	andi	a3,a2,255
   1021c:	00169693          	slli	a3,a3,0x1
   10220:	fc070ce3          	beqz	a4,101f8 <HAL_DMA_Config+0x28>
   10224:	fd1ff06f          	j	101f4 <HAL_DMA_Config+0x24>

00010228 <HAL_DMA_Start>:
   10228:	00050863          	beqz	a0,10238 <HAL_DMA_Start+0x10>
   1022c:	00c52783          	lw	a5,12(a0)
   10230:	0017e793          	ori	a5,a5,1
   10234:	00f52623          	sw	a5,12(a0)
   10238:	00008067          	ret

0001023c <HAL_DMA_Wait_Done>:
   1023c:	00050c63          	beqz	a0,10254 <HAL_DMA_Wait_Done+0x18>
   10240:	01052783          	lw	a5,16(a0)
   10244:	0027f793          	andi	a5,a5,2
   10248:	fe078ce3          	beqz	a5,10240 <HAL_DMA_Wait_Done+0x4>
   1024c:	00100793          	li	a5,1
   10250:	00f52c23          	sw	a5,24(a0)
   10254:	00008067          	ret
   10258:	00008067          	ret

0001025c <HAL_DMA_IRQHandler>:
   1025c:	04050a63          	beqz	a0,102b0 <HAL_DMA_IRQHandler+0x54>
   10260:	01852783          	lw	a5,24(a0)
   10264:	ff010113          	addi	sp,sp,-16
   10268:	00812423          	sw	s0,8(sp)
   1026c:	00112623          	sw	ra,12(sp)
   10270:	0017f793          	andi	a5,a5,1
   10274:	00050413          	mv	s0,a0
   10278:	02079463          	bnez	a5,102a0 <HAL_DMA_IRQHandler+0x44>
   1027c:	01842783          	lw	a5,24(s0)
   10280:	0027f793          	andi	a5,a5,2
   10284:	00078663          	beqz	a5,10290 <HAL_DMA_IRQHandler+0x34>
   10288:	00200793          	li	a5,2
   1028c:	00f42c23          	sw	a5,24(s0)
   10290:	00c12083          	lw	ra,12(sp)
   10294:	00812403          	lw	s0,8(sp)
   10298:	01010113          	addi	sp,sp,16
   1029c:	00008067          	ret
   102a0:	00100793          	li	a5,1
   102a4:	00f52c23          	sw	a5,24(a0)
   102a8:	29c000ef          	jal	ra,10544 <HAL_DMA_TransferCompleteCallback>
   102ac:	fd1ff06f          	j	1027c <HAL_DMA_IRQHandler+0x20>
   102b0:	00008067          	ret

000102b4 <HAL_GPIO_Init>:
   102b4:	08050063          	beqz	a0,10334 <HAL_GPIO_Init+0x80>
   102b8:	06058e63          	beqz	a1,10334 <HAL_GPIO_Init+0x80>
   102bc:	0005a883          	lw	a7,0(a1)
   102c0:	00000793          	li	a5,0
   102c4:	00100613          	li	a2,1
   102c8:	00200e13          	li	t3,2
   102cc:	02000813          	li	a6,32
   102d0:	02c0006f          	j	102fc <HAL_GPIO_Init+0x48>
   102d4:	fff74313          	not	t1,a4
   102d8:	06069063          	bnez	a3,10338 <HAL_GPIO_Init+0x84>
   102dc:	00852703          	lw	a4,8(a0)
   102e0:	00677733          	and	a4,a4,t1
   102e4:	00e52423          	sw	a4,8(a0)
   102e8:	00c52703          	lw	a4,12(a0)
   102ec:	00e37333          	and	t1,t1,a4
   102f0:	00652623          	sw	t1,12(a0)
   102f4:	00178793          	addi	a5,a5,1
   102f8:	03078e63          	beq	a5,a6,10334 <HAL_GPIO_Init+0x80>
   102fc:	00f61733          	sll	a4,a2,a5
   10300:	011776b3          	and	a3,a4,a7
   10304:	fe0688e3          	beqz	a3,102f4 <HAL_GPIO_Init+0x40>
   10308:	0045a683          	lw	a3,4(a1)
   1030c:	fcc694e3          	bne	a3,a2,102d4 <HAL_GPIO_Init+0x20>
   10310:	00852303          	lw	t1,8(a0)
   10314:	fff74693          	not	a3,a4
   10318:	00178793          	addi	a5,a5,1
   1031c:	00e36733          	or	a4,t1,a4
   10320:	00e52423          	sw	a4,8(a0)
   10324:	00c52703          	lw	a4,12(a0)
   10328:	00e6f733          	and	a4,a3,a4
   1032c:	00e52623          	sw	a4,12(a0)
   10330:	fd0796e3          	bne	a5,a6,102fc <HAL_GPIO_Init+0x48>
   10334:	00008067          	ret
   10338:	fbc69ee3          	bne	a3,t3,102f4 <HAL_GPIO_Init+0x40>
   1033c:	00852303          	lw	t1,8(a0)
   10340:	fff74693          	not	a3,a4
   10344:	0066f6b3          	and	a3,a3,t1
   10348:	00d52423          	sw	a3,8(a0)
   1034c:	00c52683          	lw	a3,12(a0)
   10350:	00e6e733          	or	a4,a3,a4
   10354:	00e52623          	sw	a4,12(a0)
   10358:	f9dff06f          	j	102f4 <HAL_GPIO_Init+0x40>

0001035c <HAL_GPIO_WritePin>:
   1035c:	00050e63          	beqz	a0,10378 <HAL_GPIO_WritePin+0x1c>
   10360:	00100793          	li	a5,1
   10364:	00f60c63          	beq	a2,a5,1037c <HAL_GPIO_WritePin+0x20>
   10368:	00452783          	lw	a5,4(a0)
   1036c:	fff5c593          	not	a1,a1
   10370:	00f5f5b3          	and	a1,a1,a5
   10374:	00b52223          	sw	a1,4(a0)
   10378:	00008067          	ret
   1037c:	00452783          	lw	a5,4(a0)
   10380:	00f5e5b3          	or	a1,a1,a5
   10384:	00b52223          	sw	a1,4(a0)
   10388:	00008067          	ret

0001038c <HAL_GPIO_TogglePin>:
   1038c:	00050863          	beqz	a0,1039c <HAL_GPIO_TogglePin+0x10>
   10390:	00452783          	lw	a5,4(a0)
   10394:	00f5c5b3          	xor	a1,a1,a5
   10398:	00b52223          	sw	a1,4(a0)
   1039c:	00008067          	ret

000103a0 <HAL_GPIO_ReadPin>:
   103a0:	00050a63          	beqz	a0,103b4 <HAL_GPIO_ReadPin+0x14>
   103a4:	00052783          	lw	a5,0(a0)
   103a8:	00f5f5b3          	and	a1,a1,a5
   103ac:	00b03533          	snez	a0,a1
   103b0:	00008067          	ret
   103b4:	00000513          	li	a0,0
   103b8:	00008067          	ret
   103bc:	00008067          	ret

000103c0 <HAL_GPIO_IRQHandler>:
   103c0:	08050663          	beqz	a0,1044c <HAL_GPIO_IRQHandler+0x8c>
   103c4:	fe010113          	addi	sp,sp,-32
   103c8:	01052783          	lw	a5,16(a0)
   103cc:	00912a23          	sw	s1,20(sp)
   103d0:	00c52483          	lw	s1,12(a0)
   103d4:	00812c23          	sw	s0,24(sp)
   103d8:	01212823          	sw	s2,16(sp)
   103dc:	01312623          	sw	s3,12(sp)
   103e0:	01412423          	sw	s4,8(sp)
   103e4:	00112e23          	sw	ra,28(sp)
   103e8:	00050a13          	mv	s4,a0
   103ec:	00000413          	li	s0,0
   103f0:	00100993          	li	s3,1
   103f4:	00f4f4b3          	and	s1,s1,a5
   103f8:	02000913          	li	s2,32
   103fc:	00c0006f          	j	10408 <HAL_GPIO_IRQHandler+0x48>
   10400:	00140413          	addi	s0,s0,1
   10404:	03240463          	beq	s0,s2,1042c <HAL_GPIO_IRQHandler+0x6c>
   10408:	008997b3          	sll	a5,s3,s0
   1040c:	00f4f733          	and	a4,s1,a5
   10410:	fe0708e3          	beqz	a4,10400 <HAL_GPIO_IRQHandler+0x40>
   10414:	01079513          	slli	a0,a5,0x10
   10418:	01055513          	srli	a0,a0,0x10
   1041c:	00fa2823          	sw	a5,16(s4)
   10420:	00140413          	addi	s0,s0,1
   10424:	108000ef          	jal	ra,1052c <HAL_GPIO_EXTI_Callback>
   10428:	ff2410e3          	bne	s0,s2,10408 <HAL_GPIO_IRQHandler+0x48>
   1042c:	01c12083          	lw	ra,28(sp)
   10430:	01812403          	lw	s0,24(sp)
   10434:	01412483          	lw	s1,20(sp)
   10438:	01012903          	lw	s2,16(sp)
   1043c:	00c12983          	lw	s3,12(sp)
   10440:	00812a03          	lw	s4,8(sp)
   10444:	02010113          	addi	sp,sp,32
   10448:	00008067          	ret
   1044c:	00008067          	ret

00010450 <i2c_init>:
   10450:	400047b7          	lui	a5,0x40004
   10454:	00a7a023          	sw	a0,0(a5) # 40004000 <_etext+0x3fff3570>
   10458:	00008067          	ret

0001045c <i2c_start>:
   1045c:	40004737          	lui	a4,0x40004
   10460:	08000793          	li	a5,128
   10464:	00f72623          	sw	a5,12(a4) # 4000400c <_etext+0x3fff357c>
   10468:	01072783          	lw	a5,16(a4)
   1046c:	0027f793          	andi	a5,a5,2
   10470:	fe079ce3          	bnez	a5,10468 <i2c_start+0xc>
   10474:	00008067          	ret

00010478 <i2c_stop>:
   10478:	40004737          	lui	a4,0x40004
   1047c:	04000793          	li	a5,64
   10480:	00f72623          	sw	a5,12(a4) # 4000400c <_etext+0x3fff357c>
   10484:	01072783          	lw	a5,16(a4)
   10488:	0027f793          	andi	a5,a5,2
   1048c:	fe079ce3          	bnez	a5,10484 <i2c_stop+0xc>
   10490:	00008067          	ret

00010494 <i2c_write>:
   10494:	40004737          	lui	a4,0x40004
   10498:	00a72223          	sw	a0,4(a4) # 40004004 <_etext+0x3fff3574>
   1049c:	01000793          	li	a5,16
   104a0:	00f72623          	sw	a5,12(a4)
   104a4:	01072783          	lw	a5,16(a4)
   104a8:	0027f793          	andi	a5,a5,2
   104ac:	fe079ce3          	bnez	a5,104a4 <i2c_write+0x10>
   104b0:	01072503          	lw	a0,16(a4)
   104b4:	00755513          	srli	a0,a0,0x7
   104b8:	00157513          	andi	a0,a0,1
   104bc:	00008067          	ret

000104c0 <i2c_read>:
   104c0:	00a03533          	snez	a0,a0
   104c4:	00351513          	slli	a0,a0,0x3
   104c8:	02050513          	addi	a0,a0,32
   104cc:	40004737          	lui	a4,0x40004
   104d0:	00a72623          	sw	a0,12(a4) # 4000400c <_etext+0x3fff357c>
   104d4:	01072783          	lw	a5,16(a4)
   104d8:	0027f793          	andi	a5,a5,2
   104dc:	fe079ce3          	bnez	a5,104d4 <i2c_read+0x14>
   104e0:	00872503          	lw	a0,8(a4)
   104e4:	0ff57513          	andi	a0,a0,255
   104e8:	00008067          	ret

000104ec <HAL_UART_RxCallback>:
   104ec:	00052703          	lw	a4,0(a0)
   104f0:	400007b7          	lui	a5,0x40000
   104f4:	00f70463          	beq	a4,a5,104fc <HAL_UART_RxCallback+0x10>
   104f8:	00008067          	ret
   104fc:	03100793          	li	a5,49
   10500:	00f58e63          	beq	a1,a5,1051c <HAL_UART_RxCallback+0x30>
   10504:	03000793          	li	a5,48
   10508:	fef598e3          	bne	a1,a5,104f8 <HAL_UART_RxCallback+0xc>
   1050c:	00000613          	li	a2,0
   10510:	00100593          	li	a1,1
   10514:	40001537          	lui	a0,0x40001
   10518:	e45ff06f          	j	1035c <HAL_GPIO_WritePin>
   1051c:	00100613          	li	a2,1
   10520:	00060593          	mv	a1,a2
   10524:	40001537          	lui	a0,0x40001
   10528:	e35ff06f          	j	1035c <HAL_GPIO_WritePin>

0001052c <HAL_GPIO_EXTI_Callback>:
   1052c:	00200793          	li	a5,2
   10530:	00f50463          	beq	a0,a5,10538 <HAL_GPIO_EXTI_Callback+0xc>
   10534:	00008067          	ret
   10538:	00100593          	li	a1,1
   1053c:	40001537          	lui	a0,0x40001
   10540:	e4dff06f          	j	1038c <HAL_GPIO_TogglePin>

00010544 <HAL_DMA_TransferCompleteCallback>:
   10544:	00008067          	ret

00010548 <plic_set_priority>:
   10548:	110007b7          	lui	a5,0x11000
   1054c:	00f50533          	add	a0,a0,a5
   10550:	0075f593          	andi	a1,a1,7
   10554:	00251513          	slli	a0,a0,0x2
   10558:	00b52023          	sw	a1,0(a0) # 40001000 <_etext+0x3fff0570>
   1055c:	00008067          	ret

00010560 <plic_enable_interrupt>:
   10560:	44002737          	lui	a4,0x44002
   10564:	00072683          	lw	a3,0(a4) # 44002000 <_etext+0x43ff1570>
   10568:	00100793          	li	a5,1
   1056c:	00a797b3          	sll	a5,a5,a0
   10570:	00d7e7b3          	or	a5,a5,a3
   10574:	00f72023          	sw	a5,0(a4)
   10578:	00008067          	ret

0001057c <plic_disable_interrupt>:
   1057c:	44002737          	lui	a4,0x44002
   10580:	00072683          	lw	a3,0(a4) # 44002000 <_etext+0x43ff1570>
   10584:	00100793          	li	a5,1
   10588:	00a797b3          	sll	a5,a5,a0
   1058c:	fff7c793          	not	a5,a5
   10590:	00d7f7b3          	and	a5,a5,a3
   10594:	00f72023          	sw	a5,0(a4)
   10598:	00008067          	ret

0001059c <plic_set_threshold>:
   1059c:	00757513          	andi	a0,a0,7
   105a0:	440047b7          	lui	a5,0x44004
   105a4:	00a7a023          	sw	a0,0(a5) # 44004000 <_etext+0x43ff3570>
   105a8:	00008067          	ret

000105ac <plic_claim>:
   105ac:	440047b7          	lui	a5,0x44004
   105b0:	0047a503          	lw	a0,4(a5) # 44004004 <_etext+0x43ff3574>
   105b4:	00008067          	ret

000105b8 <plic_complete>:
   105b8:	00050663          	beqz	a0,105c4 <plic_complete+0xc>
   105bc:	440047b7          	lui	a5,0x44004
   105c0:	00a7a223          	sw	a0,4(a5) # 44004004 <_etext+0x43ff3574>
   105c4:	00008067          	ret

000105c8 <spi_init>:
   105c8:	00151513          	slli	a0,a0,0x1
   105cc:	00257513          	andi	a0,a0,2
   105d0:	0015f593          	andi	a1,a1,1
   105d4:	400037b7          	lui	a5,0x40003
   105d8:	00b56533          	or	a0,a0,a1
   105dc:	00a7a023          	sw	a0,0(a5) # 40003000 <_etext+0x3fff2570>
   105e0:	00c7a423          	sw	a2,8(a5)
   105e4:	00100713          	li	a4,1
   105e8:	00e7a223          	sw	a4,4(a5)
   105ec:	00008067          	ret

000105f0 <spi_set_cs>:
   105f0:	00157513          	andi	a0,a0,1
   105f4:	400037b7          	lui	a5,0x40003
   105f8:	00a7a223          	sw	a0,4(a5) # 40003004 <_etext+0x3fff2574>
   105fc:	00008067          	ret

00010600 <spi_transfer>:
   10600:	40003737          	lui	a4,0x40003
   10604:	01472783          	lw	a5,20(a4) # 40003014 <_etext+0x3fff2584>
   10608:	0017f793          	andi	a5,a5,1
   1060c:	fe079ce3          	bnez	a5,10604 <spi_transfer+0x4>
   10610:	00a72623          	sw	a0,12(a4)
   10614:	40003737          	lui	a4,0x40003
   10618:	01472783          	lw	a5,20(a4) # 40003014 <_etext+0x3fff2584>
   1061c:	0027f793          	andi	a5,a5,2
   10620:	fe078ce3          	beqz	a5,10618 <spi_transfer+0x18>
   10624:	01072503          	lw	a0,16(a4)
   10628:	0ff57513          	andi	a0,a0,255
   1062c:	00008067          	ret

00010630 <_sbrk>:
   10630:	80000737          	lui	a4,0x80000
   10634:	01072783          	lw	a5,16(a4) # 80000010 <_estack+0xffff0010>
   10638:	00078a63          	beqz	a5,1064c <_sbrk+0x1c>
   1063c:	00a78533          	add	a0,a5,a0
   10640:	00a72823          	sw	a0,16(a4)
   10644:	00078513          	mv	a0,a5
   10648:	00008067          	ret
   1064c:	800007b7          	lui	a5,0x80000
   10650:	01478793          	addi	a5,a5,20 # 80000014 <_estack+0xffff0014>
   10654:	00a78533          	add	a0,a5,a0
   10658:	00a72823          	sw	a0,16(a4)
   1065c:	00078513          	mv	a0,a5
   10660:	00008067          	ret

00010664 <_write>:
   10664:	ff010113          	addi	sp,sp,-16
   10668:	00812423          	sw	s0,8(sp)
   1066c:	80000537          	lui	a0,0x80000
   10670:	00060413          	mv	s0,a2
   10674:	01061613          	slli	a2,a2,0x10
   10678:	00850513          	addi	a0,a0,8 # 80000008 <_estack+0xffff0008>
   1067c:	01065613          	srli	a2,a2,0x10
   10680:	00112623          	sw	ra,12(sp)
   10684:	190000ef          	jal	ra,10814 <HAL_UART_Transmit>
   10688:	00c12083          	lw	ra,12(sp)
   1068c:	00040513          	mv	a0,s0
   10690:	00812403          	lw	s0,8(sp)
   10694:	01010113          	addi	sp,sp,16
   10698:	00008067          	ret

0001069c <_close>:
   1069c:	fff00513          	li	a0,-1
   106a0:	00008067          	ret

000106a4 <_fstat>:
   106a4:	00000513          	li	a0,0
   106a8:	00008067          	ret

000106ac <_isatty>:
   106ac:	00100513          	li	a0,1
   106b0:	00008067          	ret

000106b4 <_lseek>:
   106b4:	00000513          	li	a0,0
   106b8:	00008067          	ret

000106bc <_read>:
   106bc:	00000513          	li	a0,0
   106c0:	00008067          	ret

000106c4 <syscon_enable_clock>:
   106c4:	00600793          	li	a5,6
   106c8:	00a7ee63          	bltu	a5,a0,106e4 <syscon_enable_clock+0x20>
   106cc:	40007737          	lui	a4,0x40007
   106d0:	00472683          	lw	a3,4(a4) # 40007004 <_etext+0x3fff6574>
   106d4:	00100793          	li	a5,1
   106d8:	00a797b3          	sll	a5,a5,a0
   106dc:	00d7e7b3          	or	a5,a5,a3
   106e0:	00f72223          	sw	a5,4(a4)
   106e4:	00008067          	ret

000106e8 <syscon_disable_clock>:
   106e8:	00600793          	li	a5,6
   106ec:	02a7e063          	bltu	a5,a0,1070c <syscon_disable_clock+0x24>
   106f0:	40007737          	lui	a4,0x40007
   106f4:	00472683          	lw	a3,4(a4) # 40007004 <_etext+0x3fff6574>
   106f8:	00100793          	li	a5,1
   106fc:	00a797b3          	sll	a5,a5,a0
   10700:	fff7c793          	not	a5,a5
   10704:	00d7f7b3          	and	a5,a5,a3
   10708:	00f72223          	sw	a5,4(a4)
   1070c:	00008067          	ret

00010710 <syscon_set_boot_address>:
   10710:	400077b7          	lui	a5,0x40007
   10714:	00a7a023          	sw	a0,0(a5) # 40007000 <_etext+0x3fff6570>
   10718:	00008067          	ret

0001071c <syscon_init_clocks>:
   1071c:	400077b7          	lui	a5,0x40007
   10720:	05e00713          	li	a4,94
   10724:	00e7a223          	sw	a4,4(a5) # 40007004 <_etext+0x3fff6574>
   10728:	00008067          	ret

0001072c <system_trap_handler>:
   1072c:	800007b7          	lui	a5,0x80000
   10730:	00b78793          	addi	a5,a5,11 # 8000000b <_estack+0xffff000b>
   10734:	02f50463          	beq	a0,a5,1075c <system_trap_handler+0x30>
   10738:	800007b7          	lui	a5,0x80000
   1073c:	00778793          	addi	a5,a5,7 # 80000007 <_estack+0xffff0007>
   10740:	04f50c63          	beq	a0,a5,10798 <system_trap_handler+0x6c>
   10744:	800007b7          	lui	a5,0x80000
   10748:	00378793          	addi	a5,a5,3 # 80000003 <_estack+0xffff0003>
   1074c:	04f50463          	beq	a0,a5,10794 <system_trap_handler+0x68>
   10750:	10500073          	wfi
   10754:	10500073          	wfi
   10758:	ff9ff06f          	j	10750 <system_trap_handler+0x24>
   1075c:	ff010113          	addi	sp,sp,-16
   10760:	00812423          	sw	s0,8(sp)
   10764:	00112623          	sw	ra,12(sp)
   10768:	e45ff0ef          	jal	ra,105ac <plic_claim>
   1076c:	00100793          	li	a5,1
   10770:	00050413          	mv	s0,a0
   10774:	02f50a63          	beq	a0,a5,107a8 <system_trap_handler+0x7c>
   10778:	00800793          	li	a5,8
   1077c:	04f50663          	beq	a0,a5,107c8 <system_trap_handler+0x9c>
   10780:	02051a63          	bnez	a0,107b4 <system_trap_handler+0x88>
   10784:	00c12083          	lw	ra,12(sp)
   10788:	00812403          	lw	s0,8(sp)
   1078c:	01010113          	addi	sp,sp,16
   10790:	00008067          	ret
   10794:	9a1ff06f          	j	10134 <clint_clear_soft_irq>
   10798:	0bebc5b7          	lui	a1,0xbebc
   1079c:	20058593          	addi	a1,a1,512 # bebc200 <_etext+0xbeab770>
   107a0:	3e800513          	li	a0,1000
   107a4:	921ff06f          	j	100c4 <clint_set_timer_ms>
   107a8:	80000537          	lui	a0,0x80000
   107ac:	00850513          	addi	a0,a0,8 # 80000008 <_estack+0xffff0008>
   107b0:	0c0000ef          	jal	ra,10870 <HAL_UART_IRQHandler>
   107b4:	00040513          	mv	a0,s0
   107b8:	00812403          	lw	s0,8(sp)
   107bc:	00c12083          	lw	ra,12(sp)
   107c0:	01010113          	addi	sp,sp,16
   107c4:	df5ff06f          	j	105b8 <plic_complete>
   107c8:	40001537          	lui	a0,0x40001
   107cc:	bf5ff0ef          	jal	ra,103c0 <HAL_GPIO_IRQHandler>
   107d0:	fe5ff06f          	j	107b4 <system_trap_handler+0x88>

000107d4 <HAL_UART_Init>:
   107d4:	02050e63          	beqz	a0,10810 <HAL_UART_Init+0x3c>
   107d8:	00052783          	lw	a5,0(a0) # 40001000 <_etext+0x3fff0570>
   107dc:	02078a63          	beqz	a5,10810 <HAL_UART_Init+0x3c>
   107e0:	02c5d733          	divu	a4,a1,a2
   107e4:	00461613          	slli	a2,a2,0x4
   107e8:	00200813          	li	a6,2
   107ec:	00100693          	li	a3,1
   107f0:	02c5d5b3          	divu	a1,a1,a2
   107f4:	01071713          	slli	a4,a4,0x10
   107f8:	01075713          	srli	a4,a4,0x10
   107fc:	01059593          	slli	a1,a1,0x10
   10800:	00e5e5b3          	or	a1,a1,a4
   10804:	00b7a023          	sw	a1,0(a5)
   10808:	0107a823          	sw	a6,16(a5)
   1080c:	00d52223          	sw	a3,4(a0)
   10810:	00008067          	ret

00010814 <HAL_UART_Transmit>:
   10814:	00452703          	lw	a4,4(a0)
   10818:	00100793          	li	a5,1
   1081c:	04f71663          	bne	a4,a5,10868 <HAL_UART_Transmit+0x54>
   10820:	04058463          	beqz	a1,10868 <HAL_UART_Transmit+0x54>
   10824:	04060263          	beqz	a2,10868 <HAL_UART_Transmit+0x54>
   10828:	00052703          	lw	a4,0(a0)
   1082c:	00300793          	li	a5,3
   10830:	00c586b3          	add	a3,a1,a2
   10834:	00f52223          	sw	a5,4(a0)
   10838:	00c72783          	lw	a5,12(a4)
   1083c:	0047f793          	andi	a5,a5,4
   10840:	fe079ce3          	bnez	a5,10838 <HAL_UART_Transmit+0x24>
   10844:	0005c783          	lbu	a5,0(a1)
   10848:	00158593          	addi	a1,a1,1
   1084c:	00f72223          	sw	a5,4(a4)
   10850:	fed594e3          	bne	a1,a3,10838 <HAL_UART_Transmit+0x24>
   10854:	00c72783          	lw	a5,12(a4)
   10858:	0107f793          	andi	a5,a5,16
   1085c:	fe079ce3          	bnez	a5,10854 <HAL_UART_Transmit+0x40>
   10860:	00100793          	li	a5,1
   10864:	00f52223          	sw	a5,4(a0)
   10868:	00008067          	ret
   1086c:	00008067          	ret

00010870 <HAL_UART_IRQHandler>:
   10870:	00052703          	lw	a4,0(a0)
   10874:	00c72783          	lw	a5,12(a4)
   10878:	0087f793          	andi	a5,a5,8
   1087c:	00078463          	beqz	a5,10884 <HAL_UART_IRQHandler+0x14>
   10880:	00008067          	ret
   10884:	00872583          	lw	a1,8(a4)
   10888:	0ff5f593          	andi	a1,a1,255
   1088c:	c61ff06f          	j	104ec <HAL_UART_RxCallback>

00010890 <HAL_WDT_Init>:
   10890:	00050c63          	beqz	a0,108a8 <HAL_WDT_Init+0x18>
   10894:	00b52023          	sw	a1,0(a0)
   10898:	00300793          	li	a5,3
   1089c:	00f52423          	sw	a5,8(a0)
   108a0:	00100793          	li	a5,1
   108a4:	00f52623          	sw	a5,12(a0)
   108a8:	00008067          	ret

000108ac <HAL_WDT_Refresh>:
   108ac:	00050663          	beqz	a0,108b8 <HAL_WDT_Refresh+0xc>
   108b0:	00100793          	li	a5,1
   108b4:	00f52623          	sw	a5,12(a0)
   108b8:	00008067          	ret
   108bc:	0000                	unimp
	...

000108c0 <trap_entry>:
   108c0:	f8010113          	addi	sp,sp,-128
   108c4:	00112023          	sw	ra,0(sp)
   108c8:	00512223          	sw	t0,4(sp)
   108cc:	00612423          	sw	t1,8(sp)
   108d0:	00712623          	sw	t2,12(sp)
   108d4:	00a12823          	sw	a0,16(sp)
   108d8:	00b12a23          	sw	a1,20(sp)
   108dc:	00c12c23          	sw	a2,24(sp)
   108e0:	00d12e23          	sw	a3,28(sp)
   108e4:	02e12023          	sw	a4,32(sp)
   108e8:	02f12223          	sw	a5,36(sp)
   108ec:	03012423          	sw	a6,40(sp)
   108f0:	03112623          	sw	a7,44(sp)
   108f4:	03c12823          	sw	t3,48(sp)
   108f8:	03d12a23          	sw	t4,52(sp)
   108fc:	03e12c23          	sw	t5,56(sp)
   10900:	03f12e23          	sw	t6,60(sp)
   10904:	34202573          	csrr	a0,mcause
   10908:	341025f3          	csrr	a1,mepc
   1090c:	e21ff0ef          	jal	ra,1072c <system_trap_handler>
   10910:	00012083          	lw	ra,0(sp)
   10914:	00412283          	lw	t0,4(sp)
   10918:	00812303          	lw	t1,8(sp)
   1091c:	00c12383          	lw	t2,12(sp)
   10920:	01012503          	lw	a0,16(sp)
   10924:	01412583          	lw	a1,20(sp)
   10928:	01812603          	lw	a2,24(sp)
   1092c:	01c12683          	lw	a3,28(sp)
   10930:	02012703          	lw	a4,32(sp)
   10934:	02412783          	lw	a5,36(sp)
   10938:	02812803          	lw	a6,40(sp)
   1093c:	02c12883          	lw	a7,44(sp)
   10940:	03012e03          	lw	t3,48(sp)
   10944:	03412e83          	lw	t4,52(sp)
   10948:	03812f03          	lw	t5,56(sp)
   1094c:	03c12f83          	lw	t6,60(sp)
   10950:	08010113          	addi	sp,sp,128
   10954:	30200073          	mret
	...

00010960 <main>:
   10960:	fd010113          	addi	sp,sp,-48
   10964:	02112623          	sw	ra,44(sp)
   10968:	02812423          	sw	s0,40(sp)
   1096c:	db1ff0ef          	jal	ra,1071c <syscon_init_clocks>
   10970:	80000437          	lui	s0,0x80000
   10974:	0001c637          	lui	a2,0x1c
   10978:	05f5e5b7          	lui	a1,0x5f5e
   1097c:	400007b7          	lui	a5,0x40000
   10980:	00840513          	addi	a0,s0,8 # 80000008 <_estack+0xffff0008>
   10984:	20060613          	addi	a2,a2,512 # 1c200 <_etext+0xb770>
   10988:	10058593          	addi	a1,a1,256 # 5f5e100 <_etext+0x5f4d670>
   1098c:	00f42423          	sw	a5,8(s0)
   10990:	e45ff0ef          	jal	ra,107d4 <HAL_UART_Init>
   10994:	eecff0ef          	jal	ra,10080 <clint_init>
   10998:	000117b7          	lui	a5,0x11
   1099c:	a8078793          	addi	a5,a5,-1408 # 10a80 <main+0x120>
   109a0:	0007a883          	lw	a7,0(a5)
   109a4:	0047a803          	lw	a6,4(a5)
   109a8:	0087a683          	lw	a3,8(a5)
   109ac:	00c7d703          	lhu	a4,12(a5)
   109b0:	00e7c783          	lbu	a5,14(a5)
   109b4:	00e00613          	li	a2,14
   109b8:	00840513          	addi	a0,s0,8
   109bc:	01010593          	addi	a1,sp,16
   109c0:	01112823          	sw	a7,16(sp)
   109c4:	01012a23          	sw	a6,20(sp)
   109c8:	00d12c23          	sw	a3,24(sp)
   109cc:	00e11e23          	sh	a4,28(sp)
   109d0:	00f10f23          	sb	a5,30(sp)
   109d4:	e41ff0ef          	jal	ra,10814 <HAL_UART_Transmit>
   109d8:	00100413          	li	s0,1
   109dc:	00810593          	addi	a1,sp,8
   109e0:	40001537          	lui	a0,0x40001
   109e4:	00812423          	sw	s0,8(sp)
   109e8:	00812623          	sw	s0,12(sp)
   109ec:	8c9ff0ef          	jal	ra,102b4 <HAL_GPIO_Init>
   109f0:	00200793          	li	a5,2
   109f4:	00810593          	addi	a1,sp,8
   109f8:	40001537          	lui	a0,0x40001
   109fc:	00f12423          	sw	a5,8(sp)
   10a00:	00f12623          	sw	a5,12(sp)
   10a04:	8b1ff0ef          	jal	ra,102b4 <HAL_GPIO_Init>
   10a08:	00000513          	li	a0,0
   10a0c:	b91ff0ef          	jal	ra,1059c <plic_set_threshold>
   10a10:	00040513          	mv	a0,s0
   10a14:	00700593          	li	a1,7
   10a18:	b31ff0ef          	jal	ra,10548 <plic_set_priority>
   10a1c:	00040513          	mv	a0,s0
   10a20:	b41ff0ef          	jal	ra,10560 <plic_enable_interrupt>
   10a24:	00500593          	li	a1,5
   10a28:	00800513          	li	a0,8
   10a2c:	b1dff0ef          	jal	ra,10548 <plic_set_priority>
   10a30:	00800513          	li	a0,8
   10a34:	b2dff0ef          	jal	ra,10560 <plic_enable_interrupt>
   10a38:	000062b7          	lui	t0,0x6
   10a3c:	3002a073          	csrs	mstatus,t0
   10a40:	000085b7          	lui	a1,0x8
   10a44:	00040513          	mv	a0,s0
   10a48:	e7cff0ef          	jal	ra,100c4 <clint_set_timer_ms>
   10a4c:	000017b7          	lui	a5,0x1
   10a50:	88078793          	addi	a5,a5,-1920 # 880 <_start-0xf780>
   10a54:	3047a073          	csrs	mie,a5
   10a58:	00800793          	li	a5,8
   10a5c:	3007a073          	csrs	mstatus,a5
   10a60:	17d785b7          	lui	a1,0x17d78
   10a64:	40058593          	addi	a1,a1,1024 # 17d78400 <_etext+0x17d67970>
   10a68:	40005537          	lui	a0,0x40005
   10a6c:	e25ff0ef          	jal	ra,10890 <HAL_WDT_Init>
   10a70:	40005537          	lui	a0,0x40005
   10a74:	e39ff0ef          	jal	ra,108ac <HAL_WDT_Refresh>
   10a78:	10500073          	wfi
   10a7c:	ff5ff06f          	j	10a70 <main+0x110>
   10a80:	4548                	lw	a0,12(a0)
   10a82:	4c4c                	lw	a1,28(s0)
   10a84:	4952204f          	fnmadd.s	ft0,ft4,fs5,fs1,rdn
   10a88:	562d4353          	0x562d4353
   10a8c:	0a21                	addi	s4,s4,8
	...
