
my_soc_firmware.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
       0:	30001073          	csrw	mstatus,zero
       4:	30401073          	csrw	mie,zero
       8:	000062b7          	lui	t0,0x6
       c:	3002a073          	csrs	mstatus,t0
      10:	00301073          	fscsr	zero
      14:	20020117          	auipc	sp,0x20020
      18:	fec10113          	addi	sp,sp,-20 # 20020000 <_estack>
      1c:	20000517          	auipc	a0,0x20000
      20:	fe450513          	addi	a0,a0,-28 # 20000000 <dst_arr>
      24:	20000597          	auipc	a1,0x20000
      28:	fe458593          	addi	a1,a1,-28 # 20000008 <_impure_ptr>
      2c:	00003617          	auipc	a2,0x3
      30:	66460613          	addi	a2,a2,1636 # 3690 <_etext>

00000034 <copy_data_loop>:
      34:	00b55c63          	bge	a0,a1,4c <copy_data_done>
      38:	00062283          	lw	t0,0(a2)
      3c:	00552023          	sw	t0,0(a0)
      40:	00450513          	addi	a0,a0,4
      44:	00460613          	addi	a2,a2,4
      48:	fedff06f          	j	34 <copy_data_loop>

0000004c <copy_data_done>:
      4c:	20000517          	auipc	a0,0x20000
      50:	01850513          	addi	a0,a0,24 # 20000064 <__sf>
      54:	20000597          	auipc	a1,0x20000
      58:	18458593          	addi	a1,a1,388 # 200001d8 <_ebss>

0000005c <clear_bss_loop>:
      5c:	00b55863          	bge	a0,a1,6c <clear_bss_done>
      60:	00052023          	sw	zero,0(a0)
      64:	00450513          	addi	a0,a0,4
      68:	ff5ff06f          	j	5c <clear_bss_loop>

0000006c <clear_bss_done>:
      6c:	00001297          	auipc	t0,0x1
      70:	a2428293          	addi	t0,t0,-1500 # a90 <trap_entry>
      74:	30529073          	csrw	mtvec,t0
      78:	335000ef          	jal	ra,bac <main>

0000007c <hang>:
      7c:	0000006f          	j	7c <hang>

00000080 <clint_init>:
      80:	020047b7          	lui	a5,0x2004
      84:	fff00713          	li	a4,-1
      88:	00e7a223          	sw	a4,4(a5) # 2004004 <_etext+0x2000974>
      8c:	020047b7          	lui	a5,0x2004
      90:	00e7a023          	sw	a4,0(a5) # 2004000 <_etext+0x2000970>
      94:	020007b7          	lui	a5,0x2000
      98:	0007a023          	sw	zero,0(a5) # 2000000 <_etext+0x1ffc970>
      9c:	00008067          	ret

000000a0 <clint_get_mtime>:
      a0:	0200c7b7          	lui	a5,0x200c
      a4:	00078693          	mv	a3,a5
      a8:	ff868693          	addi	a3,a3,-8
      ac:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x200896c>
      b0:	0007a703          	lw	a4,0(a5)
      b4:	0006a503          	lw	a0,0(a3)
      b8:	0007a583          	lw	a1,0(a5)
      bc:	fee59ae3          	bne	a1,a4,b0 <clint_get_mtime+0x10>
      c0:	00008067          	ret

000000c4 <clint_set_timer_ms>:
      c4:	0200c7b7          	lui	a5,0x200c
      c8:	00078813          	mv	a6,a5
      cc:	ff880813          	addi	a6,a6,-8
      d0:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x200896c>
      d4:	0007a703          	lw	a4,0(a5)
      d8:	00082603          	lw	a2,0(a6)
      dc:	0007a683          	lw	a3,0(a5)
      e0:	fed71ae3          	bne	a4,a3,d4 <clint_set_timer_ms+0x10>
      e4:	106257b7          	lui	a5,0x10625
      e8:	dd378793          	addi	a5,a5,-557 # 10624dd3 <_etext+0x10621743>
      ec:	02f5b7b3          	mulhu	a5,a1,a5
      f0:	fff00693          	li	a3,-1
      f4:	020045b7          	lui	a1,0x2004
      f8:	00d5a223          	sw	a3,4(a1) # 2004004 <_etext+0x2000974>
      fc:	0067d793          	srli	a5,a5,0x6
     100:	02a786b3          	mul	a3,a5,a0
     104:	02a7b7b3          	mulhu	a5,a5,a0
     108:	00c68633          	add	a2,a3,a2
     10c:	00d636b3          	sltu	a3,a2,a3
     110:	00c5a023          	sw	a2,0(a1)
     114:	00e787b3          	add	a5,a5,a4
     118:	00f686b3          	add	a3,a3,a5
     11c:	00d5a223          	sw	a3,4(a1)
     120:	00008067          	ret

00000124 <clint_trigger_soft_irq>:
     124:	020007b7          	lui	a5,0x2000
     128:	00100713          	li	a4,1
     12c:	00e7a023          	sw	a4,0(a5) # 2000000 <_etext+0x1ffc970>
     130:	00008067          	ret

00000134 <clint_clear_soft_irq>:
     134:	020007b7          	lui	a5,0x2000
     138:	0007a023          	sw	zero,0(a5) # 2000000 <_etext+0x1ffc970>
     13c:	00008067          	ret

00000140 <HAL_Delay>:
     140:	0200c7b7          	lui	a5,0x200c
     144:	00078693          	mv	a3,a5
     148:	ff868693          	addi	a3,a3,-8
     14c:	ffc78793          	addi	a5,a5,-4 # 200bffc <_etext+0x200896c>
     150:	0007a803          	lw	a6,0(a5)
     154:	0006a883          	lw	a7,0(a3)
     158:	0007a703          	lw	a4,0(a5)
     15c:	fee81ae3          	bne	a6,a4,150 <HAL_Delay+0x10>
     160:	106257b7          	lui	a5,0x10625
     164:	dd378793          	addi	a5,a5,-557 # 10624dd3 <_etext+0x10621743>
     168:	02f5b7b3          	mulhu	a5,a1,a5
     16c:	0200c737          	lui	a4,0x200c
     170:	00070593          	mv	a1,a4
     174:	ff858593          	addi	a1,a1,-8
     178:	ffc70713          	addi	a4,a4,-4 # 200bffc <_etext+0x200896c>
     17c:	0067d793          	srli	a5,a5,0x6
     180:	02a78333          	mul	t1,a5,a0
     184:	02a7b533          	mulhu	a0,a5,a0
     188:	00072783          	lw	a5,0(a4)
     18c:	0005a603          	lw	a2,0(a1)
     190:	00072683          	lw	a3,0(a4)
     194:	fed79ae3          	bne	a5,a3,188 <HAL_Delay+0x48>
     198:	411606b3          	sub	a3,a2,a7
     19c:	410787b3          	sub	a5,a5,a6
     1a0:	00d63633          	sltu	a2,a2,a3
     1a4:	40c787b3          	sub	a5,a5,a2
     1a8:	00a7f663          	bgeu	a5,a0,1b4 <HAL_Delay+0x74>
     1ac:	00000013          	nop
     1b0:	fd9ff06f          	j	188 <HAL_Delay+0x48>
     1b4:	00f51463          	bne	a0,a5,1bc <HAL_Delay+0x7c>
     1b8:	fe66eae3          	bltu	a3,t1,1ac <HAL_Delay+0x6c>
     1bc:	00008067          	ret

000001c0 <HAL_DMA_Init>:
     1c0:	400097b7          	lui	a5,0x40009
     1c4:	00100713          	li	a4,1
     1c8:	f0e7a023          	sw	a4,-256(a5) # 40008f00 <_estack+0x1ffe8f00>
     1cc:	00008067          	ret

000001d0 <HAL_DMA_Config>:
     1d0:	04050263          	beqz	a0,214 <HAL_DMA_Config+0x44>
     1d4:	00b52023          	sw	a1,0(a0)
     1d8:	00c52223          	sw	a2,4(a0)
     1dc:	00d52423          	sw	a3,8(a0)
     1e0:	04000613          	li	a2,64
     1e4:	0ff87693          	andi	a3,a6,255
     1e8:	03066863          	bltu	a2,a6,218 <HAL_DMA_Config+0x48>
     1ec:	00169693          	slli	a3,a3,0x1
     1f0:	00070463          	beqz	a4,1f8 <HAL_DMA_Config+0x28>
     1f4:	1006e693          	ori	a3,a3,256
     1f8:	00078463          	beqz	a5,200 <HAL_DMA_Config+0x30>
     1fc:	2006e693          	ori	a3,a3,512
     200:	00a89893          	slli	a7,a7,0xa
     204:	00d8e8b3          	or	a7,a7,a3
     208:	01152623          	sw	a7,12(a0)
     20c:	00300793          	li	a5,3
     210:	00f52a23          	sw	a5,20(a0)
     214:	00008067          	ret
     218:	0ff67693          	andi	a3,a2,255
     21c:	00169693          	slli	a3,a3,0x1
     220:	fc070ce3          	beqz	a4,1f8 <HAL_DMA_Config+0x28>
     224:	fd1ff06f          	j	1f4 <HAL_DMA_Config+0x24>

00000228 <HAL_DMA_Start>:
     228:	00050863          	beqz	a0,238 <HAL_DMA_Start+0x10>
     22c:	00c52783          	lw	a5,12(a0)
     230:	0017e793          	ori	a5,a5,1
     234:	00f52623          	sw	a5,12(a0)
     238:	00008067          	ret

0000023c <HAL_DMA_Wait_Done>:
     23c:	00050c63          	beqz	a0,254 <HAL_DMA_Wait_Done+0x18>
     240:	01052783          	lw	a5,16(a0)
     244:	0027f793          	andi	a5,a5,2
     248:	fe078ce3          	beqz	a5,240 <HAL_DMA_Wait_Done+0x4>
     24c:	00100793          	li	a5,1
     250:	00f52c23          	sw	a5,24(a0)
     254:	00008067          	ret
     258:	00008067          	ret

0000025c <HAL_DMA_IRQHandler>:
     25c:	04050a63          	beqz	a0,2b0 <HAL_DMA_IRQHandler+0x54>
     260:	01852783          	lw	a5,24(a0)
     264:	ff010113          	addi	sp,sp,-16
     268:	00812423          	sw	s0,8(sp)
     26c:	00112623          	sw	ra,12(sp)
     270:	0017f793          	andi	a5,a5,1
     274:	00050413          	mv	s0,a0
     278:	02079463          	bnez	a5,2a0 <HAL_DMA_IRQHandler+0x44>
     27c:	01842783          	lw	a5,24(s0)
     280:	0027f793          	andi	a5,a5,2
     284:	00078663          	beqz	a5,290 <HAL_DMA_IRQHandler+0x34>
     288:	00200793          	li	a5,2
     28c:	00f42c23          	sw	a5,24(s0)
     290:	00c12083          	lw	ra,12(sp)
     294:	00812403          	lw	s0,8(sp)
     298:	01010113          	addi	sp,sp,16
     29c:	00008067          	ret
     2a0:	00100793          	li	a5,1
     2a4:	00f52c23          	sw	a5,24(a0)
     2a8:	230000ef          	jal	ra,4d8 <HAL_DMA_TransferCompleteCallback>
     2ac:	fd1ff06f          	j	27c <HAL_DMA_IRQHandler+0x20>
     2b0:	00008067          	ret

000002b4 <gpio_set_direction>:
     2b4:	01f00793          	li	a5,31
     2b8:	02a7e263          	bltu	a5,a0,2dc <gpio_set_direction+0x28>
     2bc:	00100793          	li	a5,1
     2c0:	00a79533          	sll	a0,a5,a0
     2c4:	00f58e63          	beq	a1,a5,2e0 <gpio_set_direction+0x2c>
     2c8:	400017b7          	lui	a5,0x40001
     2cc:	0087a703          	lw	a4,8(a5) # 40001008 <_estack+0x1ffe1008>
     2d0:	fff54513          	not	a0,a0
     2d4:	00e57533          	and	a0,a0,a4
     2d8:	00a7a423          	sw	a0,8(a5)
     2dc:	00008067          	ret
     2e0:	400017b7          	lui	a5,0x40001
     2e4:	0087a703          	lw	a4,8(a5) # 40001008 <_estack+0x1ffe1008>
     2e8:	00e56533          	or	a0,a0,a4
     2ec:	00a7a423          	sw	a0,8(a5)
     2f0:	00008067          	ret

000002f4 <gpio_write_pin>:
     2f4:	01f00793          	li	a5,31
     2f8:	02a7e863          	bltu	a5,a0,328 <gpio_write_pin+0x34>
     2fc:	40001737          	lui	a4,0x40001
     300:	00472683          	lw	a3,4(a4) # 40001004 <_estack+0x1ffe1004>
     304:	00100793          	li	a5,1
     308:	00a797b3          	sll	a5,a5,a0
     30c:	00058863          	beqz	a1,31c <gpio_write_pin+0x28>
     310:	00d7e7b3          	or	a5,a5,a3
     314:	00f72223          	sw	a5,4(a4)
     318:	00008067          	ret
     31c:	fff7c793          	not	a5,a5
     320:	00d7f7b3          	and	a5,a5,a3
     324:	00f72223          	sw	a5,4(a4)
     328:	00008067          	ret

0000032c <gpio_read_pin>:
     32c:	01f00793          	li	a5,31
     330:	02a7e063          	bltu	a5,a0,350 <gpio_read_pin+0x24>
     334:	400017b7          	lui	a5,0x40001
     338:	0007a703          	lw	a4,0(a5) # 40001000 <_estack+0x1ffe1000>
     33c:	00100793          	li	a5,1
     340:	00a79533          	sll	a0,a5,a0
     344:	00e57533          	and	a0,a0,a4
     348:	00a03533          	snez	a0,a0
     34c:	00008067          	ret
     350:	00000513          	li	a0,0
     354:	00008067          	ret

00000358 <gpio_enable_interrupt>:
     358:	01f00793          	li	a5,31
     35c:	00a7ee63          	bltu	a5,a0,378 <gpio_enable_interrupt+0x20>
     360:	40001737          	lui	a4,0x40001
     364:	00c72683          	lw	a3,12(a4) # 4000100c <_estack+0x1ffe100c>
     368:	00100793          	li	a5,1
     36c:	00a797b3          	sll	a5,a5,a0
     370:	00d7e7b3          	or	a5,a5,a3
     374:	00f72623          	sw	a5,12(a4)
     378:	00008067          	ret

0000037c <gpio_disable_interrupt>:
     37c:	01f00793          	li	a5,31
     380:	02a7e063          	bltu	a5,a0,3a0 <gpio_disable_interrupt+0x24>
     384:	40001737          	lui	a4,0x40001
     388:	00c72683          	lw	a3,12(a4) # 4000100c <_estack+0x1ffe100c>
     38c:	00100793          	li	a5,1
     390:	00a797b3          	sll	a5,a5,a0
     394:	fff7c793          	not	a5,a5
     398:	00d7f7b3          	and	a5,a5,a3
     39c:	00f72623          	sw	a5,12(a4)
     3a0:	00008067          	ret

000003a4 <gpio_get_interrupt_status>:
     3a4:	400017b7          	lui	a5,0x40001
     3a8:	0107a503          	lw	a0,16(a5) # 40001010 <_estack+0x1ffe1010>
     3ac:	00008067          	ret

000003b0 <gpio_clear_interrupt>:
     3b0:	01f00793          	li	a5,31
     3b4:	00a7ea63          	bltu	a5,a0,3c8 <gpio_clear_interrupt+0x18>
     3b8:	00100793          	li	a5,1
     3bc:	00a797b3          	sll	a5,a5,a0
     3c0:	40001737          	lui	a4,0x40001
     3c4:	00f72823          	sw	a5,16(a4) # 40001010 <_estack+0x1ffe1010>
     3c8:	00008067          	ret

000003cc <i2c_init>:
     3cc:	400047b7          	lui	a5,0x40004
     3d0:	00a7a023          	sw	a0,0(a5) # 40004000 <_estack+0x1ffe4000>
     3d4:	00008067          	ret

000003d8 <i2c_start>:
     3d8:	40004737          	lui	a4,0x40004
     3dc:	08000793          	li	a5,128
     3e0:	00f72623          	sw	a5,12(a4) # 4000400c <_estack+0x1ffe400c>
     3e4:	01072783          	lw	a5,16(a4)
     3e8:	0027f793          	andi	a5,a5,2
     3ec:	fe079ce3          	bnez	a5,3e4 <i2c_start+0xc>
     3f0:	00008067          	ret

000003f4 <i2c_stop>:
     3f4:	40004737          	lui	a4,0x40004
     3f8:	04000793          	li	a5,64
     3fc:	00f72623          	sw	a5,12(a4) # 4000400c <_estack+0x1ffe400c>
     400:	01072783          	lw	a5,16(a4)
     404:	0027f793          	andi	a5,a5,2
     408:	fe079ce3          	bnez	a5,400 <i2c_stop+0xc>
     40c:	00008067          	ret

00000410 <i2c_write>:
     410:	40004737          	lui	a4,0x40004
     414:	00a72223          	sw	a0,4(a4) # 40004004 <_estack+0x1ffe4004>
     418:	01000793          	li	a5,16
     41c:	00f72623          	sw	a5,12(a4)
     420:	01072783          	lw	a5,16(a4)
     424:	0027f793          	andi	a5,a5,2
     428:	fe079ce3          	bnez	a5,420 <i2c_write+0x10>
     42c:	01072503          	lw	a0,16(a4)
     430:	00755513          	srli	a0,a0,0x7
     434:	00157513          	andi	a0,a0,1
     438:	00008067          	ret

0000043c <i2c_read>:
     43c:	00a03533          	snez	a0,a0
     440:	00351513          	slli	a0,a0,0x3
     444:	02050513          	addi	a0,a0,32
     448:	40004737          	lui	a4,0x40004
     44c:	00a72623          	sw	a0,12(a4) # 4000400c <_estack+0x1ffe400c>
     450:	01072783          	lw	a5,16(a4)
     454:	0027f793          	andi	a5,a5,2
     458:	fe079ce3          	bnez	a5,450 <i2c_read+0x14>
     45c:	00872503          	lw	a0,8(a4)
     460:	0ff57513          	andi	a0,a0,255
     464:	00008067          	ret

00000468 <HAL_UART_RxCallback>:
     468:	00052703          	lw	a4,0(a0)
     46c:	400007b7          	lui	a5,0x40000
     470:	00f70463          	beq	a4,a5,478 <HAL_UART_RxCallback+0x10>
     474:	00008067          	ret
     478:	00003537          	lui	a0,0x3
     47c:	ff010113          	addi	sp,sp,-16
     480:	41450513          	addi	a0,a0,1044 # 3414 <__errno+0x194>
     484:	00812423          	sw	s0,8(sp)
     488:	00112623          	sw	ra,12(sp)
     48c:	00058413          	mv	s0,a1
     490:	10d000ef          	jal	ra,d9c <iprintf>
     494:	03100793          	li	a5,49
     498:	00f40e63          	beq	s0,a5,4b4 <HAL_UART_RxCallback+0x4c>
     49c:	03000793          	li	a5,48
     4a0:	02f40663          	beq	s0,a5,4cc <HAL_UART_RxCallback+0x64>
     4a4:	00c12083          	lw	ra,12(sp)
     4a8:	00812403          	lw	s0,8(sp)
     4ac:	01010113          	addi	sp,sp,16
     4b0:	00008067          	ret
     4b4:	00003537          	lui	a0,0x3
     4b8:	43450513          	addi	a0,a0,1076 # 3434 <__errno+0x1b4>
     4bc:	00812403          	lw	s0,8(sp)
     4c0:	00c12083          	lw	ra,12(sp)
     4c4:	01010113          	addi	sp,sp,16
     4c8:	27d0006f          	j	f44 <puts>
     4cc:	00003537          	lui	a0,0x3
     4d0:	46050513          	addi	a0,a0,1120 # 3460 <__errno+0x1e0>
     4d4:	fe9ff06f          	j	4bc <HAL_UART_RxCallback+0x54>

000004d8 <HAL_DMA_TransferCompleteCallback>:
     4d8:	400087b7          	lui	a5,0x40008
     4dc:	00f50463          	beq	a0,a5,4e4 <HAL_DMA_TransferCompleteCallback+0xc>
     4e0:	00008067          	ret
     4e4:	00003537          	lui	a0,0x3
     4e8:	ff010113          	addi	sp,sp,-16
     4ec:	48c50513          	addi	a0,a0,1164 # 348c <__errno+0x20c>
     4f0:	00112623          	sw	ra,12(sp)
     4f4:	251000ef          	jal	ra,f44 <puts>
     4f8:	200007b7          	lui	a5,0x20000
     4fc:	0007a783          	lw	a5,0(a5) # 20000000 <dst_arr>
     500:	00c12083          	lw	ra,12(sp)
     504:	00003537          	lui	a0,0x3
     508:	0007a583          	lw	a1,0(a5)
     50c:	4b850513          	addi	a0,a0,1208 # 34b8 <__errno+0x238>
     510:	01010113          	addi	sp,sp,16
     514:	0890006f          	j	d9c <iprintf>

00000518 <plic_set_priority>:
     518:	110007b7          	lui	a5,0x11000
     51c:	00f50533          	add	a0,a0,a5
     520:	0075f593          	andi	a1,a1,7
     524:	00251513          	slli	a0,a0,0x2
     528:	00b52023          	sw	a1,0(a0)
     52c:	00008067          	ret

00000530 <plic_enable_interrupt>:
     530:	44002737          	lui	a4,0x44002
     534:	00072683          	lw	a3,0(a4) # 44002000 <_estack+0x23fe2000>
     538:	00100793          	li	a5,1
     53c:	00a797b3          	sll	a5,a5,a0
     540:	00d7e7b3          	or	a5,a5,a3
     544:	00f72023          	sw	a5,0(a4)
     548:	00008067          	ret

0000054c <plic_disable_interrupt>:
     54c:	44002737          	lui	a4,0x44002
     550:	00072683          	lw	a3,0(a4) # 44002000 <_estack+0x23fe2000>
     554:	00100793          	li	a5,1
     558:	00a797b3          	sll	a5,a5,a0
     55c:	fff7c793          	not	a5,a5
     560:	00d7f7b3          	and	a5,a5,a3
     564:	00f72023          	sw	a5,0(a4)
     568:	00008067          	ret

0000056c <plic_set_threshold>:
     56c:	00757513          	andi	a0,a0,7
     570:	440047b7          	lui	a5,0x44004
     574:	00a7a023          	sw	a0,0(a5) # 44004000 <_estack+0x23fe4000>
     578:	00008067          	ret

0000057c <plic_claim>:
     57c:	440047b7          	lui	a5,0x44004
     580:	0047a503          	lw	a0,4(a5) # 44004004 <_estack+0x23fe4004>
     584:	00008067          	ret

00000588 <plic_complete>:
     588:	00050663          	beqz	a0,594 <plic_complete+0xc>
     58c:	440047b7          	lui	a5,0x44004
     590:	00a7a223          	sw	a0,4(a5) # 44004004 <_estack+0x23fe4004>
     594:	00008067          	ret

00000598 <spi_init>:
     598:	00151513          	slli	a0,a0,0x1
     59c:	00257513          	andi	a0,a0,2
     5a0:	0015f593          	andi	a1,a1,1
     5a4:	400037b7          	lui	a5,0x40003
     5a8:	00b56533          	or	a0,a0,a1
     5ac:	00a7a023          	sw	a0,0(a5) # 40003000 <_estack+0x1ffe3000>
     5b0:	00c7a423          	sw	a2,8(a5)
     5b4:	00100713          	li	a4,1
     5b8:	00e7a223          	sw	a4,4(a5)
     5bc:	00008067          	ret

000005c0 <spi_set_cs>:
     5c0:	00157513          	andi	a0,a0,1
     5c4:	400037b7          	lui	a5,0x40003
     5c8:	00a7a223          	sw	a0,4(a5) # 40003004 <_estack+0x1ffe3004>
     5cc:	00008067          	ret

000005d0 <spi_transfer>:
     5d0:	40003737          	lui	a4,0x40003
     5d4:	01472783          	lw	a5,20(a4) # 40003014 <_estack+0x1ffe3014>
     5d8:	0017f793          	andi	a5,a5,1
     5dc:	fe079ce3          	bnez	a5,5d4 <spi_transfer+0x4>
     5e0:	00a72623          	sw	a0,12(a4)
     5e4:	40003737          	lui	a4,0x40003
     5e8:	01472783          	lw	a5,20(a4) # 40003014 <_estack+0x1ffe3014>
     5ec:	0027f793          	andi	a5,a5,2
     5f0:	fe078ce3          	beqz	a5,5e8 <spi_transfer+0x18>
     5f4:	01072503          	lw	a0,16(a4)
     5f8:	0ff57513          	andi	a0,a0,255
     5fc:	00008067          	ret

00000600 <_sbrk>:
     600:	20000737          	lui	a4,0x20000
     604:	1a472783          	lw	a5,420(a4) # 200001a4 <heap_end.0>
     608:	00078a63          	beqz	a5,61c <_sbrk+0x1c>
     60c:	00a78533          	add	a0,a5,a0
     610:	1aa72223          	sw	a0,420(a4)
     614:	00078513          	mv	a0,a5
     618:	00008067          	ret
     61c:	200007b7          	lui	a5,0x20000
     620:	1d878793          	addi	a5,a5,472 # 200001d8 <_ebss>
     624:	00a78533          	add	a0,a5,a0
     628:	1aa72223          	sw	a0,420(a4)
     62c:	00078513          	mv	a0,a5
     630:	00008067          	ret

00000634 <_close>:
     634:	fff00513          	li	a0,-1
     638:	00008067          	ret

0000063c <_fstat>:
     63c:	00000513          	li	a0,0
     640:	00008067          	ret

00000644 <_isatty>:
     644:	00100513          	li	a0,1
     648:	00008067          	ret

0000064c <_lseek>:
     64c:	00000513          	li	a0,0
     650:	00008067          	ret

00000654 <_read>:
     654:	00000513          	li	a0,0
     658:	00008067          	ret

0000065c <syscon_enable_clock>:
     65c:	00600793          	li	a5,6
     660:	00a7ee63          	bltu	a5,a0,67c <syscon_enable_clock+0x20>
     664:	40007737          	lui	a4,0x40007
     668:	00472683          	lw	a3,4(a4) # 40007004 <_estack+0x1ffe7004>
     66c:	00100793          	li	a5,1
     670:	00a797b3          	sll	a5,a5,a0
     674:	00d7e7b3          	or	a5,a5,a3
     678:	00f72223          	sw	a5,4(a4)
     67c:	00008067          	ret

00000680 <syscon_disable_clock>:
     680:	00600793          	li	a5,6
     684:	02a7e063          	bltu	a5,a0,6a4 <syscon_disable_clock+0x24>
     688:	40007737          	lui	a4,0x40007
     68c:	00472683          	lw	a3,4(a4) # 40007004 <_estack+0x1ffe7004>
     690:	00100793          	li	a5,1
     694:	00a797b3          	sll	a5,a5,a0
     698:	fff7c793          	not	a5,a5
     69c:	00d7f7b3          	and	a5,a5,a3
     6a0:	00f72223          	sw	a5,4(a4)
     6a4:	00008067          	ret

000006a8 <syscon_set_boot_address>:
     6a8:	400077b7          	lui	a5,0x40007
     6ac:	00a7a023          	sw	a0,0(a5) # 40007000 <_estack+0x1ffe7000>
     6b0:	00008067          	ret

000006b4 <syscon_init_clocks>:
     6b4:	400077b7          	lui	a5,0x40007
     6b8:	05e00713          	li	a4,94
     6bc:	00e7a223          	sw	a4,4(a5) # 40007004 <_estack+0x1ffe7004>
     6c0:	00008067          	ret

000006c4 <system_trap_handler>:
     6c4:	fe010113          	addi	sp,sp,-32
     6c8:	800007b7          	lui	a5,0x80000
     6cc:	00112e23          	sw	ra,28(sp)
     6d0:	00b78793          	addi	a5,a5,11 # 8000000b <_estack+0x5ffe000b>
     6d4:	08f50663          	beq	a0,a5,760 <system_trap_handler+0x9c>
     6d8:	800007b7          	lui	a5,0x80000
     6dc:	00812c23          	sw	s0,24(sp)
     6e0:	00778793          	addi	a5,a5,7 # 80000007 <_estack+0x5ffe0007>
     6e4:	00050413          	mv	s0,a0
     6e8:	0cf50663          	beq	a0,a5,7b4 <system_trap_handler+0xf0>
     6ec:	800007b7          	lui	a5,0x80000
     6f0:	00378793          	addi	a5,a5,3 # 80000003 <_estack+0x5ffe0003>
     6f4:	04f50863          	beq	a0,a5,744 <system_trap_handler+0x80>
     6f8:	00003537          	lui	a0,0x3
     6fc:	52050513          	addi	a0,a0,1312 # 3520 <__errno+0x2a0>
     700:	00912a23          	sw	s1,20(sp)
     704:	00058493          	mv	s1,a1
     708:	03d000ef          	jal	ra,f44 <puts>
     70c:	00003537          	lui	a0,0x3
     710:	00048613          	mv	a2,s1
     714:	00040593          	mv	a1,s0
     718:	54050513          	addi	a0,a0,1344 # 3540 <__errno+0x2c0>
     71c:	680000ef          	jal	ra,d9c <iprintf>
     720:	00200793          	li	a5,2
     724:	0af40c63          	beq	s0,a5,7dc <system_trap_handler+0x118>
     728:	00500793          	li	a5,5
     72c:	0cf40263          	beq	s0,a5,7f0 <system_trap_handler+0x12c>
     730:	00700793          	li	a5,7
     734:	06f40663          	beq	s0,a5,7a0 <system_trap_handler+0xdc>
     738:	10500073          	wfi
     73c:	10500073          	wfi
     740:	ff9ff06f          	j	738 <system_trap_handler+0x74>
     744:	00003537          	lui	a0,0x3
     748:	4fc50513          	addi	a0,a0,1276 # 34fc <__errno+0x27c>
     74c:	7f8000ef          	jal	ra,f44 <puts>
     750:	01812403          	lw	s0,24(sp)
     754:	01c12083          	lw	ra,28(sp)
     758:	02010113          	addi	sp,sp,32
     75c:	9d9ff06f          	j	134 <clint_clear_soft_irq>
     760:	00912a23          	sw	s1,20(sp)
     764:	01212823          	sw	s2,16(sp)
     768:	00100493          	li	s1,1
     76c:	e11ff0ef          	jal	ra,57c <plic_claim>
     770:	00050913          	mv	s2,a0
     774:	08950863          	beq	a0,s1,804 <system_trap_handler+0x140>
     778:	00400793          	li	a5,4
     77c:	0af50663          	beq	a0,a5,828 <system_trap_handler+0x164>
     780:	00800793          	li	a5,8
     784:	0af50863          	beq	a0,a5,834 <system_trap_handler+0x170>
     788:	08051463          	bnez	a0,810 <system_trap_handler+0x14c>
     78c:	01c12083          	lw	ra,28(sp)
     790:	01412483          	lw	s1,20(sp)
     794:	01012903          	lw	s2,16(sp)
     798:	02010113          	addi	sp,sp,32
     79c:	00008067          	ret
     7a0:	00003537          	lui	a0,0x3
     7a4:	5c850513          	addi	a0,a0,1480 # 35c8 <__errno+0x348>
     7a8:	79c000ef          	jal	ra,f44 <puts>
     7ac:	10500073          	wfi
     7b0:	f8dff06f          	j	73c <system_trap_handler+0x78>
     7b4:	00003537          	lui	a0,0x3
     7b8:	4e450513          	addi	a0,a0,1252 # 34e4 <__errno+0x264>
     7bc:	788000ef          	jal	ra,f44 <puts>
     7c0:	01812403          	lw	s0,24(sp)
     7c4:	01c12083          	lw	ra,28(sp)
     7c8:	0bebc5b7          	lui	a1,0xbebc
     7cc:	20058593          	addi	a1,a1,512 # bebc200 <_etext+0xbeb8b70>
     7d0:	3e800513          	li	a0,1000
     7d4:	02010113          	addi	sp,sp,32
     7d8:	8edff06f          	j	c4 <clint_set_timer_ms>
     7dc:	00003537          	lui	a0,0x3
     7e0:	56450513          	addi	a0,a0,1380 # 3564 <__errno+0x2e4>
     7e4:	760000ef          	jal	ra,f44 <puts>
     7e8:	10500073          	wfi
     7ec:	f51ff06f          	j	73c <system_trap_handler+0x78>
     7f0:	00003537          	lui	a0,0x3
     7f4:	59850513          	addi	a0,a0,1432 # 3598 <__errno+0x318>
     7f8:	74c000ef          	jal	ra,f44 <puts>
     7fc:	10500073          	wfi
     800:	f3dff06f          	j	73c <system_trap_handler+0x78>
     804:	20000537          	lui	a0,0x20000
     808:	19c50513          	addi	a0,a0,412 # 2000019c <huart0>
     80c:	22c000ef          	jal	ra,a38 <HAL_UART_IRQHandler>
     810:	01412483          	lw	s1,20(sp)
     814:	01c12083          	lw	ra,28(sp)
     818:	00090513          	mv	a0,s2
     81c:	01012903          	lw	s2,16(sp)
     820:	02010113          	addi	sp,sp,32
     824:	d65ff06f          	j	588 <plic_complete>
     828:	40008537          	lui	a0,0x40008
     82c:	a31ff0ef          	jal	ra,25c <HAL_DMA_IRQHandler>
     830:	fe1ff06f          	j	810 <system_trap_handler+0x14c>
     834:	00812c23          	sw	s0,24(sp)
     838:	01312623          	sw	s3,12(sp)
     83c:	01412423          	sw	s4,8(sp)
     840:	b65ff0ef          	jal	ra,3a4 <gpio_get_interrupt_status>
     844:	00050993          	mv	s3,a0
     848:	00000413          	li	s0,0
     84c:	02000a13          	li	s4,32
     850:	00c0006f          	j	85c <system_trap_handler+0x198>
     854:	00140413          	addi	s0,s0,1
     858:	01440e63          	beq	s0,s4,874 <system_trap_handler+0x1b0>
     85c:	008497b3          	sll	a5,s1,s0
     860:	0137f7b3          	and	a5,a5,s3
     864:	fe0788e3          	beqz	a5,854 <system_trap_handler+0x190>
     868:	0ff47513          	andi	a0,s0,255
     86c:	b45ff0ef          	jal	ra,3b0 <gpio_clear_interrupt>
     870:	fe5ff06f          	j	854 <system_trap_handler+0x190>
     874:	01812403          	lw	s0,24(sp)
     878:	00c12983          	lw	s3,12(sp)
     87c:	00812a03          	lw	s4,8(sp)
     880:	f91ff06f          	j	810 <system_trap_handler+0x14c>

00000884 <HAL_UART_Init>:
     884:	02050a63          	beqz	a0,8b8 <HAL_UART_Init+0x34>
     888:	00052783          	lw	a5,0(a0) # 40008000 <_estack+0x1ffe8000>
     88c:	02078663          	beqz	a5,8b8 <HAL_UART_Init+0x34>
     890:	02c5d5b3          	divu	a1,a1,a2
     894:	00200693          	li	a3,2
     898:	00100713          	li	a4,1
     89c:	01059613          	slli	a2,a1,0x10
     8a0:	01065613          	srli	a2,a2,0x10
     8a4:	01059593          	slli	a1,a1,0x10
     8a8:	00c5e5b3          	or	a1,a1,a2
     8ac:	00b7a023          	sw	a1,0(a5)
     8b0:	00d7a823          	sw	a3,16(a5)
     8b4:	00e52223          	sw	a4,4(a0)
     8b8:	00008067          	ret

000008bc <HAL_UART_Transmit>:
     8bc:	00452703          	lw	a4,4(a0)
     8c0:	00100793          	li	a5,1
     8c4:	04f71663          	bne	a4,a5,910 <HAL_UART_Transmit+0x54>
     8c8:	04058463          	beqz	a1,910 <HAL_UART_Transmit+0x54>
     8cc:	04060263          	beqz	a2,910 <HAL_UART_Transmit+0x54>
     8d0:	00052703          	lw	a4,0(a0)
     8d4:	00300793          	li	a5,3
     8d8:	00c586b3          	add	a3,a1,a2
     8dc:	00f52223          	sw	a5,4(a0)
     8e0:	00c72783          	lw	a5,12(a4)
     8e4:	0047f793          	andi	a5,a5,4
     8e8:	fe079ce3          	bnez	a5,8e0 <HAL_UART_Transmit+0x24>
     8ec:	0005c783          	lbu	a5,0(a1)
     8f0:	00158593          	addi	a1,a1,1
     8f4:	00f72223          	sw	a5,4(a4)
     8f8:	fed594e3          	bne	a1,a3,8e0 <HAL_UART_Transmit+0x24>
     8fc:	00c72783          	lw	a5,12(a4)
     900:	0107f793          	andi	a5,a5,16
     904:	fe079ce3          	bnez	a5,8fc <HAL_UART_Transmit+0x40>
     908:	00100793          	li	a5,1
     90c:	00f52223          	sw	a5,4(a0)
     910:	00008067          	ret

00000914 <HAL_UART_Transmit_DMA>:
     914:	00452803          	lw	a6,4(a0)
     918:	ff010113          	addi	sp,sp,-16
     91c:	00812423          	sw	s0,8(sp)
     920:	00112623          	sw	ra,12(sp)
     924:	00050413          	mv	s0,a0
     928:	00100513          	li	a0,1
     92c:	04a81e63          	bne	a6,a0,988 <HAL_UART_Transmit_DMA+0x74>
     930:	04060c63          	beqz	a2,988 <HAL_UART_Transmit_DMA+0x74>
     934:	04068a63          	beqz	a3,988 <HAL_UART_Transmit_DMA+0x74>
     938:	00912223          	sw	s1,4(sp)
     93c:	00058493          	mv	s1,a1
     940:	04058c63          	beqz	a1,998 <HAL_UART_Transmit_DMA+0x84>
     944:	00042503          	lw	a0,0(s0)
     948:	00300793          	li	a5,3
     94c:	00070893          	mv	a7,a4
     950:	00060593          	mv	a1,a2
     954:	00080713          	mv	a4,a6
     958:	00450613          	addi	a2,a0,4
     95c:	00f42223          	sw	a5,4(s0)
     960:	00048513          	mv	a0,s1
     964:	00000793          	li	a5,0
     968:	869ff0ef          	jal	ra,1d0 <HAL_DMA_Config>
     96c:	00048513          	mv	a0,s1
     970:	8b9ff0ef          	jal	ra,228 <HAL_DMA_Start>
     974:	00042703          	lw	a4,0(s0)
     978:	00412483          	lw	s1,4(sp)
     97c:	01072783          	lw	a5,16(a4)
     980:	0047e793          	ori	a5,a5,4
     984:	00f72823          	sw	a5,16(a4)
     988:	00c12083          	lw	ra,12(sp)
     98c:	00812403          	lw	s0,8(sp)
     990:	01010113          	addi	sp,sp,16
     994:	00008067          	ret
     998:	00412483          	lw	s1,4(sp)
     99c:	fedff06f          	j	988 <HAL_UART_Transmit_DMA+0x74>

000009a0 <HAL_UART_Receive_DMA>:
     9a0:	00452803          	lw	a6,4(a0)
     9a4:	ff010113          	addi	sp,sp,-16
     9a8:	00812423          	sw	s0,8(sp)
     9ac:	00112623          	sw	ra,12(sp)
     9b0:	00050413          	mv	s0,a0
     9b4:	00100513          	li	a0,1
     9b8:	04a81c63          	bne	a6,a0,a10 <HAL_UART_Receive_DMA+0x70>
     9bc:	04060a63          	beqz	a2,a10 <HAL_UART_Receive_DMA+0x70>
     9c0:	00912223          	sw	s1,4(sp)
     9c4:	00058493          	mv	s1,a1
     9c8:	04068c63          	beqz	a3,a20 <HAL_UART_Receive_DMA+0x80>
     9cc:	04048a63          	beqz	s1,a20 <HAL_UART_Receive_DMA+0x80>
     9d0:	00042583          	lw	a1,0(s0)
     9d4:	00400793          	li	a5,4
     9d8:	00070893          	mv	a7,a4
     9dc:	00048513          	mv	a0,s1
     9e0:	00000713          	li	a4,0
     9e4:	00858593          	addi	a1,a1,8
     9e8:	00f42223          	sw	a5,4(s0)
     9ec:	00080793          	mv	a5,a6
     9f0:	fe0ff0ef          	jal	ra,1d0 <HAL_DMA_Config>
     9f4:	00048513          	mv	a0,s1
     9f8:	831ff0ef          	jal	ra,228 <HAL_DMA_Start>
     9fc:	00042703          	lw	a4,0(s0)
     a00:	00412483          	lw	s1,4(sp)
     a04:	01072783          	lw	a5,16(a4)
     a08:	0087e793          	ori	a5,a5,8
     a0c:	00f72823          	sw	a5,16(a4)
     a10:	00c12083          	lw	ra,12(sp)
     a14:	00812403          	lw	s0,8(sp)
     a18:	01010113          	addi	sp,sp,16
     a1c:	00008067          	ret
     a20:	00c12083          	lw	ra,12(sp)
     a24:	00812403          	lw	s0,8(sp)
     a28:	00412483          	lw	s1,4(sp)
     a2c:	01010113          	addi	sp,sp,16
     a30:	00008067          	ret
     a34:	00008067          	ret

00000a38 <HAL_UART_IRQHandler>:
     a38:	00052703          	lw	a4,0(a0)
     a3c:	00c72783          	lw	a5,12(a4)
     a40:	0087f793          	andi	a5,a5,8
     a44:	00078463          	beqz	a5,a4c <HAL_UART_IRQHandler+0x14>
     a48:	00008067          	ret
     a4c:	00872583          	lw	a1,8(a4)
     a50:	0ff5f593          	andi	a1,a1,255
     a54:	a15ff06f          	j	468 <HAL_UART_RxCallback>

00000a58 <HAL_WDT_Init>:
     a58:	00050c63          	beqz	a0,a70 <HAL_WDT_Init+0x18>
     a5c:	00b52023          	sw	a1,0(a0)
     a60:	00300793          	li	a5,3
     a64:	00f52423          	sw	a5,8(a0)
     a68:	00100793          	li	a5,1
     a6c:	00f52623          	sw	a5,12(a0)
     a70:	00008067          	ret

00000a74 <HAL_WDT_Refresh>:
     a74:	00050663          	beqz	a0,a80 <HAL_WDT_Refresh+0xc>
     a78:	00100793          	li	a5,1
     a7c:	00f52623          	sw	a5,12(a0)
     a80:	00008067          	ret
	...

00000a90 <trap_entry>:
     a90:	f8010113          	addi	sp,sp,-128
     a94:	00112023          	sw	ra,0(sp)
     a98:	00512223          	sw	t0,4(sp)
     a9c:	00612423          	sw	t1,8(sp)
     aa0:	00712623          	sw	t2,12(sp)
     aa4:	00a12823          	sw	a0,16(sp)
     aa8:	00b12a23          	sw	a1,20(sp)
     aac:	00c12c23          	sw	a2,24(sp)
     ab0:	00d12e23          	sw	a3,28(sp)
     ab4:	02e12023          	sw	a4,32(sp)
     ab8:	02f12223          	sw	a5,36(sp)
     abc:	03012423          	sw	a6,40(sp)
     ac0:	03112623          	sw	a7,44(sp)
     ac4:	03c12823          	sw	t3,48(sp)
     ac8:	03d12a23          	sw	t4,52(sp)
     acc:	03e12c23          	sw	t5,56(sp)
     ad0:	03f12e23          	sw	t6,60(sp)
     ad4:	34202573          	csrr	a0,mcause
     ad8:	341025f3          	csrr	a1,mepc
     adc:	be9ff0ef          	jal	ra,6c4 <system_trap_handler>
     ae0:	00012083          	lw	ra,0(sp)
     ae4:	00412283          	lw	t0,4(sp)
     ae8:	00812303          	lw	t1,8(sp)
     aec:	00c12383          	lw	t2,12(sp)
     af0:	01012503          	lw	a0,16(sp)
     af4:	01412583          	lw	a1,20(sp)
     af8:	01812603          	lw	a2,24(sp)
     afc:	01c12683          	lw	a3,28(sp)
     b00:	02012703          	lw	a4,32(sp)
     b04:	02412783          	lw	a5,36(sp)
     b08:	02812803          	lw	a6,40(sp)
     b0c:	02c12883          	lw	a7,44(sp)
     b10:	03012e03          	lw	t3,48(sp)
     b14:	03412e83          	lw	t4,52(sp)
     b18:	03812f03          	lw	t5,56(sp)
     b1c:	03c12f83          	lw	t6,60(sp)
     b20:	08010113          	addi	sp,sp,128
     b24:	30200073          	mret
	...

00000b30 <memmove>:
     b30:	02060c63          	beqz	a2,b68 <memmove+0x38>
     b34:	00050313          	mv	t1,a0
     b38:	00100693          	li	a3,1
     b3c:	00b56a63          	bltu	a0,a1,b50 <memmove+0x20>
     b40:	fff00693          	li	a3,-1
     b44:	fff60713          	addi	a4,a2,-1
     b48:	00e30333          	add	t1,t1,a4
     b4c:	00e585b3          	add	a1,a1,a4
     b50:	00058383          	lb	t2,0(a1)
     b54:	00730023          	sb	t2,0(t1)
     b58:	fff60613          	addi	a2,a2,-1
     b5c:	00d30333          	add	t1,t1,a3
     b60:	00d585b3          	add	a1,a1,a3
     b64:	fe0616e3          	bnez	a2,b50 <memmove+0x20>
     b68:	00008067          	ret

00000b6c <memset>:
     b6c:	00050313          	mv	t1,a0
     b70:	00060a63          	beqz	a2,b84 <memset+0x18>
     b74:	00b30023          	sb	a1,0(t1)
     b78:	fff60613          	addi	a2,a2,-1
     b7c:	00130313          	addi	t1,t1,1
     b80:	fe061ae3          	bnez	a2,b74 <memset+0x8>
     b84:	00008067          	ret

00000b88 <memcpy>:
     b88:	00050313          	mv	t1,a0
     b8c:	00060e63          	beqz	a2,ba8 <memcpy+0x20>
     b90:	00058383          	lb	t2,0(a1)
     b94:	00730023          	sb	t2,0(t1)
     b98:	fff60613          	addi	a2,a2,-1
     b9c:	00130313          	addi	t1,t1,1
     ba0:	00158593          	addi	a1,a1,1
     ba4:	fe0616e3          	bnez	a2,b90 <memcpy+0x8>
     ba8:	00008067          	ret

00000bac <main>:
     bac:	ff010113          	addi	sp,sp,-16
     bb0:	00112623          	sw	ra,12(sp)
     bb4:	00812423          	sw	s0,8(sp)
     bb8:	00912223          	sw	s1,4(sp)
     bbc:	af9ff0ef          	jal	ra,6b4 <syscon_init_clocks>
     bc0:	200007b7          	lui	a5,0x20000
     bc4:	0001c637          	lui	a2,0x1c
     bc8:	0bebc5b7          	lui	a1,0xbebc
     bcc:	40000737          	lui	a4,0x40000
     bd0:	19c78513          	addi	a0,a5,412 # 2000019c <huart0>
     bd4:	20060613          	addi	a2,a2,512 # 1c200 <_etext+0x18b70>
     bd8:	20058593          	addi	a1,a1,512 # bebc200 <_etext+0xbeb8b70>
     bdc:	18e7ae23          	sw	a4,412(a5)
     be0:	ca5ff0ef          	jal	ra,884 <HAL_UART_Init>
     be4:	c9cff0ef          	jal	ra,80 <clint_init>
     be8:	00003537          	lui	a0,0x3
     bec:	28c50513          	addi	a0,a0,652 # 328c <__errno+0xc>
     bf0:	354000ef          	jal	ra,f44 <puts>
     bf4:	00003537          	lui	a0,0x3
     bf8:	2b850513          	addi	a0,a0,696 # 32b8 <__errno+0x38>
     bfc:	348000ef          	jal	ra,f44 <puts>
     c00:	00003537          	lui	a0,0x3
     c04:	2e450513          	addi	a0,a0,740 # 32e4 <__errno+0x64>
     c08:	33c000ef          	jal	ra,f44 <puts>
     c0c:	00003537          	lui	a0,0x3
     c10:	31050513          	addi	a0,a0,784 # 3310 <__errno+0x90>
     c14:	330000ef          	jal	ra,f44 <puts>
     c18:	00100593          	li	a1,1
     c1c:	00000513          	li	a0,0
     c20:	e94ff0ef          	jal	ra,2b4 <gpio_set_direction>
     c24:	00000593          	li	a1,0
     c28:	00100513          	li	a0,1
     c2c:	e88ff0ef          	jal	ra,2b4 <gpio_set_direction>
     c30:	00100513          	li	a0,1
     c34:	f24ff0ef          	jal	ra,358 <gpio_enable_interrupt>
     c38:	00000513          	li	a0,0
     c3c:	931ff0ef          	jal	ra,56c <plic_set_threshold>
     c40:	00700593          	li	a1,7
     c44:	00100513          	li	a0,1
     c48:	8d1ff0ef          	jal	ra,518 <plic_set_priority>
     c4c:	00100513          	li	a0,1
     c50:	8e1ff0ef          	jal	ra,530 <plic_enable_interrupt>
     c54:	00500593          	li	a1,5
     c58:	00800513          	li	a0,8
     c5c:	8bdff0ef          	jal	ra,518 <plic_set_priority>
     c60:	00800513          	li	a0,8
     c64:	8cdff0ef          	jal	ra,530 <plic_enable_interrupt>
     c68:	d58ff0ef          	jal	ra,1c0 <HAL_DMA_Init>
     c6c:	00600593          	li	a1,6
     c70:	00400513          	li	a0,4
     c74:	8a5ff0ef          	jal	ra,518 <plic_set_priority>
     c78:	00400513          	li	a0,4
     c7c:	8b5ff0ef          	jal	ra,530 <plic_enable_interrupt>
     c80:	00003537          	lui	a0,0x3
     c84:	33c50513          	addi	a0,a0,828 # 333c <__errno+0xbc>
     c88:	2bc000ef          	jal	ra,f44 <puts>
     c8c:	000062b7          	lui	t0,0x6
     c90:	3002a073          	csrs	mstatus,t0
     c94:	00003537          	lui	a0,0x3
     c98:	36450513          	addi	a0,a0,868 # 3364 <__errno+0xe4>
     c9c:	2a8000ef          	jal	ra,f44 <puts>
     ca0:	000085b7          	lui	a1,0x8
     ca4:	3e800513          	li	a0,1000
     ca8:	c1cff0ef          	jal	ra,c4 <clint_set_timer_ms>
     cac:	00003537          	lui	a0,0x3
     cb0:	38450513          	addi	a0,a0,900 # 3384 <__errno+0x104>
     cb4:	290000ef          	jal	ra,f44 <puts>
     cb8:	000017b7          	lui	a5,0x1
     cbc:	88078793          	addi	a5,a5,-1920 # 880 <system_trap_handler+0x1bc>
     cc0:	3047a073          	csrs	mie,a5
     cc4:	00800793          	li	a5,8
     cc8:	3007a073          	csrs	mstatus,a5
     ccc:	00003537          	lui	a0,0x3
     cd0:	3ac50513          	addi	a0,a0,940 # 33ac <__errno+0x12c>
     cd4:	270000ef          	jal	ra,f44 <puts>
     cd8:	20000437          	lui	s0,0x20000
     cdc:	200004b7          	lui	s1,0x20000
     ce0:	00442683          	lw	a3,4(s0) # 20000004 <src_arr>
     ce4:	0004a703          	lw	a4,0(s1) # 20000000 <dst_arr>
     ce8:	00000793          	li	a5,0
     cec:	00a00613          	li	a2,10
     cf0:	00178793          	addi	a5,a5,1
     cf4:	00f6a023          	sw	a5,0(a3)
     cf8:	00072023          	sw	zero,0(a4) # 40000000 <_estack+0x1ffe0000>
     cfc:	00468693          	addi	a3,a3,4
     d00:	00470713          	addi	a4,a4,4
     d04:	fec796e3          	bne	a5,a2,cf0 <main+0x144>
     d08:	00003537          	lui	a0,0x3
     d0c:	3e450513          	addi	a0,a0,996 # 33e4 <__errno+0x164>
     d10:	234000ef          	jal	ra,f44 <puts>
     d14:	00442583          	lw	a1,4(s0)
     d18:	0004a603          	lw	a2,0(s1)
     d1c:	00100793          	li	a5,1
     d20:	00078713          	mv	a4,a5
     d24:	00000893          	li	a7,0
     d28:	01000813          	li	a6,16
     d2c:	02800693          	li	a3,40
     d30:	40008537          	lui	a0,0x40008
     d34:	c9cff0ef          	jal	ra,1d0 <HAL_DMA_Config>
     d38:	40008537          	lui	a0,0x40008
     d3c:	cecff0ef          	jal	ra,228 <HAL_DMA_Start>
     d40:	17d785b7          	lui	a1,0x17d78
     d44:	40058593          	addi	a1,a1,1024 # 17d78400 <_etext+0x17d74d70>
     d48:	40005537          	lui	a0,0x40005
     d4c:	d0dff0ef          	jal	ra,a58 <HAL_WDT_Init>
     d50:	10500073          	wfi
     d54:	10500073          	wfi
     d58:	ff9ff06f          	j	d50 <main+0x1a4>

00000d5c <_iprintf_r>:
     d5c:	fc010113          	addi	sp,sp,-64
     d60:	02c12423          	sw	a2,40(sp)
     d64:	02d12623          	sw	a3,44(sp)
     d68:	02e12823          	sw	a4,48(sp)
     d6c:	02f12a23          	sw	a5,52(sp)
     d70:	03012c23          	sw	a6,56(sp)
     d74:	03112e23          	sw	a7,60(sp)
     d78:	00058613          	mv	a2,a1
     d7c:	00852583          	lw	a1,8(a0) # 40005008 <_estack+0x1ffe5008>
     d80:	02810693          	addi	a3,sp,40
     d84:	00112e23          	sw	ra,28(sp)
     d88:	00d12623          	sw	a3,12(sp)
     d8c:	07d000ef          	jal	ra,1608 <_vfiprintf_r>
     d90:	01c12083          	lw	ra,28(sp)
     d94:	04010113          	addi	sp,sp,64
     d98:	00008067          	ret

00000d9c <iprintf>:
     d9c:	fc010113          	addi	sp,sp,-64
     da0:	02f12a23          	sw	a5,52(sp)
     da4:	1ffff797          	auipc	a5,0x1ffff
     da8:	2647a783          	lw	a5,612(a5) # 20000008 <_impure_ptr>
     dac:	02c12423          	sw	a2,40(sp)
     db0:	02d12623          	sw	a3,44(sp)
     db4:	02b12223          	sw	a1,36(sp)
     db8:	02e12823          	sw	a4,48(sp)
     dbc:	03012c23          	sw	a6,56(sp)
     dc0:	03112e23          	sw	a7,60(sp)
     dc4:	0087a583          	lw	a1,8(a5)
     dc8:	02410693          	addi	a3,sp,36
     dcc:	00050613          	mv	a2,a0
     dd0:	00078513          	mv	a0,a5
     dd4:	00112e23          	sw	ra,28(sp)
     dd8:	00d12623          	sw	a3,12(sp)
     ddc:	02d000ef          	jal	ra,1608 <_vfiprintf_r>
     de0:	01c12083          	lw	ra,28(sp)
     de4:	04010113          	addi	sp,sp,64
     de8:	00008067          	ret

00000dec <_puts_r>:
     dec:	02052783          	lw	a5,32(a0)
     df0:	fe010113          	addi	sp,sp,-32
     df4:	00812c23          	sw	s0,24(sp)
     df8:	00912a23          	sw	s1,20(sp)
     dfc:	01212823          	sw	s2,16(sp)
     e00:	00112e23          	sw	ra,28(sp)
     e04:	01312623          	sw	s3,12(sp)
     e08:	01412423          	sw	s4,8(sp)
     e0c:	00852403          	lw	s0,8(a0)
     e10:	00050493          	mv	s1,a0
     e14:	00058913          	mv	s2,a1
     e18:	00079463          	bnez	a5,e20 <_puts_r+0x34>
     e1c:	730010ef          	jal	ra,254c <__sinit>
     e20:	06442783          	lw	a5,100(s0)
     e24:	0017f793          	andi	a5,a5,1
     e28:	00079c63          	bnez	a5,e40 <_puts_r+0x54>
     e2c:	00c45783          	lhu	a5,12(s0)
     e30:	2007f793          	andi	a5,a5,512
     e34:	00079663          	bnez	a5,e40 <_puts_r+0x54>
     e38:	05842503          	lw	a0,88(s0)
     e3c:	358000ef          	jal	ra,1194 <__retarget_lock_acquire_recursive>
     e40:	00c45783          	lhu	a5,12(s0)
     e44:	0087f793          	andi	a5,a5,8
     e48:	00078663          	beqz	a5,e54 <_puts_r+0x68>
     e4c:	01042783          	lw	a5,16(s0)
     e50:	0c079863          	bnez	a5,f20 <_puts_r+0x134>
     e54:	00040593          	mv	a1,s0
     e58:	00048513          	mv	a0,s1
     e5c:	20c000ef          	jal	ra,1068 <__swsetup_r>
     e60:	0c050063          	beqz	a0,f20 <_puts_r+0x134>
     e64:	fff00493          	li	s1,-1
     e68:	06442783          	lw	a5,100(s0)
     e6c:	0017f793          	andi	a5,a5,1
     e70:	00079c63          	bnez	a5,e88 <_puts_r+0x9c>
     e74:	00c45783          	lhu	a5,12(s0)
     e78:	2007f793          	andi	a5,a5,512
     e7c:	00079663          	bnez	a5,e88 <_puts_r+0x9c>
     e80:	05842503          	lw	a0,88(s0)
     e84:	328000ef          	jal	ra,11ac <__retarget_lock_release_recursive>
     e88:	01c12083          	lw	ra,28(sp)
     e8c:	01812403          	lw	s0,24(sp)
     e90:	01012903          	lw	s2,16(sp)
     e94:	00c12983          	lw	s3,12(sp)
     e98:	00812a03          	lw	s4,8(sp)
     e9c:	00048513          	mv	a0,s1
     ea0:	01412483          	lw	s1,20(sp)
     ea4:	02010113          	addi	sp,sp,32
     ea8:	00008067          	ret
     eac:	00f42423          	sw	a5,8(s0)
     eb0:	00190913          	addi	s2,s2,1
     eb4:	0007d863          	bgez	a5,ec4 <_puts_r+0xd8>
     eb8:	01842703          	lw	a4,24(s0)
     ebc:	04e7c863          	blt	a5,a4,f0c <_puts_r+0x120>
     ec0:	05458663          	beq	a1,s4,f0c <_puts_r+0x120>
     ec4:	00042783          	lw	a5,0(s0)
     ec8:	00178713          	addi	a4,a5,1
     ecc:	00e42023          	sw	a4,0(s0)
     ed0:	00b78023          	sb	a1,0(a5)
     ed4:	00842783          	lw	a5,8(s0)
     ed8:	00094583          	lbu	a1,0(s2)
     edc:	fff78793          	addi	a5,a5,-1
     ee0:	fc0596e3          	bnez	a1,eac <_puts_r+0xc0>
     ee4:	00f42423          	sw	a5,8(s0)
     ee8:	0407d263          	bgez	a5,f2c <_puts_r+0x140>
     eec:	00040613          	mv	a2,s0
     ef0:	00a00593          	li	a1,10
     ef4:	00048513          	mv	a0,s1
     ef8:	05c000ef          	jal	ra,f54 <__swbuf_r>
     efc:	fff00793          	li	a5,-1
     f00:	f6f502e3          	beq	a0,a5,e64 <_puts_r+0x78>
     f04:	00a00493          	li	s1,10
     f08:	f61ff06f          	j	e68 <_puts_r+0x7c>
     f0c:	00040613          	mv	a2,s0
     f10:	00048513          	mv	a0,s1
     f14:	040000ef          	jal	ra,f54 <__swbuf_r>
     f18:	fb351ee3          	bne	a0,s3,ed4 <_puts_r+0xe8>
     f1c:	f49ff06f          	j	e64 <_puts_r+0x78>
     f20:	fff00993          	li	s3,-1
     f24:	00a00a13          	li	s4,10
     f28:	fadff06f          	j	ed4 <_puts_r+0xe8>
     f2c:	00042783          	lw	a5,0(s0)
     f30:	00178713          	addi	a4,a5,1
     f34:	00e42023          	sw	a4,0(s0)
     f38:	00a00713          	li	a4,10
     f3c:	00e78023          	sb	a4,0(a5)
     f40:	fc5ff06f          	j	f04 <_puts_r+0x118>

00000f44 <puts>:
     f44:	00050593          	mv	a1,a0
     f48:	1ffff517          	auipc	a0,0x1ffff
     f4c:	0c052503          	lw	a0,192(a0) # 20000008 <_impure_ptr>
     f50:	e9dff06f          	j	dec <_puts_r>

00000f54 <__swbuf_r>:
     f54:	fe010113          	addi	sp,sp,-32
     f58:	00812c23          	sw	s0,24(sp)
     f5c:	00912a23          	sw	s1,20(sp)
     f60:	01212823          	sw	s2,16(sp)
     f64:	00112e23          	sw	ra,28(sp)
     f68:	01312623          	sw	s3,12(sp)
     f6c:	00050913          	mv	s2,a0
     f70:	00058493          	mv	s1,a1
     f74:	00060413          	mv	s0,a2
     f78:	00050863          	beqz	a0,f88 <__swbuf_r+0x34>
     f7c:	02052783          	lw	a5,32(a0)
     f80:	00079463          	bnez	a5,f88 <__swbuf_r+0x34>
     f84:	5c8010ef          	jal	ra,254c <__sinit>
     f88:	01842783          	lw	a5,24(s0)
     f8c:	00f42423          	sw	a5,8(s0)
     f90:	00c45783          	lhu	a5,12(s0)
     f94:	0087f793          	andi	a5,a5,8
     f98:	00078663          	beqz	a5,fa4 <__swbuf_r+0x50>
     f9c:	01042783          	lw	a5,16(s0)
     fa0:	02079c63          	bnez	a5,fd8 <__swbuf_r+0x84>
     fa4:	00040593          	mv	a1,s0
     fa8:	00090513          	mv	a0,s2
     fac:	0bc000ef          	jal	ra,1068 <__swsetup_r>
     fb0:	02050463          	beqz	a0,fd8 <__swbuf_r+0x84>
     fb4:	fff00493          	li	s1,-1
     fb8:	01c12083          	lw	ra,28(sp)
     fbc:	01812403          	lw	s0,24(sp)
     fc0:	01012903          	lw	s2,16(sp)
     fc4:	00c12983          	lw	s3,12(sp)
     fc8:	00048513          	mv	a0,s1
     fcc:	01412483          	lw	s1,20(sp)
     fd0:	02010113          	addi	sp,sp,32
     fd4:	00008067          	ret
     fd8:	00042783          	lw	a5,0(s0)
     fdc:	01042703          	lw	a4,16(s0)
     fe0:	0ff4f993          	andi	s3,s1,255
     fe4:	0ff4f493          	andi	s1,s1,255
     fe8:	40e78533          	sub	a0,a5,a4
     fec:	01442783          	lw	a5,20(s0)
     ff0:	00f54a63          	blt	a0,a5,1004 <__swbuf_r+0xb0>
     ff4:	00040593          	mv	a1,s0
     ff8:	00090513          	mv	a0,s2
     ffc:	11c010ef          	jal	ra,2118 <_fflush_r>
    1000:	fa051ae3          	bnez	a0,fb4 <__swbuf_r+0x60>
    1004:	00842783          	lw	a5,8(s0)
    1008:	fff78793          	addi	a5,a5,-1
    100c:	00f42423          	sw	a5,8(s0)
    1010:	00042783          	lw	a5,0(s0)
    1014:	00178713          	addi	a4,a5,1
    1018:	00e42023          	sw	a4,0(s0)
    101c:	01378023          	sb	s3,0(a5)
    1020:	01442703          	lw	a4,20(s0)
    1024:	00150793          	addi	a5,a0,1
    1028:	00f70c63          	beq	a4,a5,1040 <__swbuf_r+0xec>
    102c:	00c45783          	lhu	a5,12(s0)
    1030:	0017f793          	andi	a5,a5,1
    1034:	f80782e3          	beqz	a5,fb8 <__swbuf_r+0x64>
    1038:	00a00793          	li	a5,10
    103c:	f6f49ee3          	bne	s1,a5,fb8 <__swbuf_r+0x64>
    1040:	00040593          	mv	a1,s0
    1044:	00090513          	mv	a0,s2
    1048:	0d0010ef          	jal	ra,2118 <_fflush_r>
    104c:	f60506e3          	beqz	a0,fb8 <__swbuf_r+0x64>
    1050:	f65ff06f          	j	fb4 <__swbuf_r+0x60>

00001054 <__swbuf>:
    1054:	00058613          	mv	a2,a1
    1058:	00050593          	mv	a1,a0
    105c:	1ffff517          	auipc	a0,0x1ffff
    1060:	fac52503          	lw	a0,-84(a0) # 20000008 <_impure_ptr>
    1064:	ef1ff06f          	j	f54 <__swbuf_r>

00001068 <__swsetup_r>:
    1068:	ff010113          	addi	sp,sp,-16
    106c:	00912223          	sw	s1,4(sp)
    1070:	00050493          	mv	s1,a0
    1074:	1ffff517          	auipc	a0,0x1ffff
    1078:	f9452503          	lw	a0,-108(a0) # 20000008 <_impure_ptr>
    107c:	00812423          	sw	s0,8(sp)
    1080:	00112623          	sw	ra,12(sp)
    1084:	00058413          	mv	s0,a1
    1088:	00050863          	beqz	a0,1098 <__swsetup_r+0x30>
    108c:	02052783          	lw	a5,32(a0)
    1090:	00079463          	bnez	a5,1098 <__swsetup_r+0x30>
    1094:	4b8010ef          	jal	ra,254c <__sinit>
    1098:	00c41783          	lh	a5,12(s0)
    109c:	0087f713          	andi	a4,a5,8
    10a0:	06071263          	bnez	a4,1104 <__swsetup_r+0x9c>
    10a4:	0107f713          	andi	a4,a5,16
    10a8:	00071e63          	bnez	a4,10c4 <__swsetup_r+0x5c>
    10ac:	00900713          	li	a4,9
    10b0:	00e4a023          	sw	a4,0(s1)
    10b4:	0407e793          	ori	a5,a5,64
    10b8:	00f41623          	sh	a5,12(s0)
    10bc:	fff00513          	li	a0,-1
    10c0:	0940006f          	j	1154 <__swsetup_r+0xec>
    10c4:	0047f713          	andi	a4,a5,4
    10c8:	02070a63          	beqz	a4,10fc <__swsetup_r+0x94>
    10cc:	03442583          	lw	a1,52(s0)
    10d0:	00058c63          	beqz	a1,10e8 <__swsetup_r+0x80>
    10d4:	04440793          	addi	a5,s0,68
    10d8:	00f58663          	beq	a1,a5,10e4 <__swsetup_r+0x7c>
    10dc:	00048513          	mv	a0,s1
    10e0:	0d0000ef          	jal	ra,11b0 <_free_r>
    10e4:	02042a23          	sw	zero,52(s0)
    10e8:	00c41783          	lh	a5,12(s0)
    10ec:	01042703          	lw	a4,16(s0)
    10f0:	00042223          	sw	zero,4(s0)
    10f4:	fdb7f793          	andi	a5,a5,-37
    10f8:	00e42023          	sw	a4,0(s0)
    10fc:	0087e793          	ori	a5,a5,8
    1100:	00f41623          	sh	a5,12(s0)
    1104:	01042703          	lw	a4,16(s0)
    1108:	00071e63          	bnez	a4,1124 <__swsetup_r+0xbc>
    110c:	2807f793          	andi	a5,a5,640
    1110:	20000713          	li	a4,512
    1114:	00e78863          	beq	a5,a4,1124 <__swsetup_r+0xbc>
    1118:	00040593          	mv	a1,s0
    111c:	00048513          	mv	a0,s1
    1120:	26d010ef          	jal	ra,2b8c <__smakebuf_r>
    1124:	00c41783          	lh	a5,12(s0)
    1128:	0017f713          	andi	a4,a5,1
    112c:	02070e63          	beqz	a4,1168 <__swsetup_r+0x100>
    1130:	01442703          	lw	a4,20(s0)
    1134:	00042423          	sw	zero,8(s0)
    1138:	40e00733          	neg	a4,a4
    113c:	00e42c23          	sw	a4,24(s0)
    1140:	01042703          	lw	a4,16(s0)
    1144:	00000513          	li	a0,0
    1148:	00071663          	bnez	a4,1154 <__swsetup_r+0xec>
    114c:	0807f713          	andi	a4,a5,128
    1150:	f60712e3          	bnez	a4,10b4 <__swsetup_r+0x4c>
    1154:	00c12083          	lw	ra,12(sp)
    1158:	00812403          	lw	s0,8(sp)
    115c:	00412483          	lw	s1,4(sp)
    1160:	01010113          	addi	sp,sp,16
    1164:	00008067          	ret
    1168:	0027f713          	andi	a4,a5,2
    116c:	00000693          	li	a3,0
    1170:	00071463          	bnez	a4,1178 <__swsetup_r+0x110>
    1174:	01442683          	lw	a3,20(s0)
    1178:	00d42423          	sw	a3,8(s0)
    117c:	fc5ff06f          	j	1140 <__swsetup_r+0xd8>

00001180 <__retarget_lock_init>:
    1180:	00008067          	ret

00001184 <__retarget_lock_init_recursive>:
    1184:	00008067          	ret

00001188 <__retarget_lock_close>:
    1188:	00008067          	ret

0000118c <__retarget_lock_close_recursive>:
    118c:	00008067          	ret

00001190 <__retarget_lock_acquire>:
    1190:	00008067          	ret

00001194 <__retarget_lock_acquire_recursive>:
    1194:	00008067          	ret

00001198 <__retarget_lock_try_acquire>:
    1198:	00100513          	li	a0,1
    119c:	00008067          	ret

000011a0 <__retarget_lock_try_acquire_recursive>:
    11a0:	00100513          	li	a0,1
    11a4:	00008067          	ret

000011a8 <__retarget_lock_release>:
    11a8:	00008067          	ret

000011ac <__retarget_lock_release_recursive>:
    11ac:	00008067          	ret

000011b0 <_free_r>:
    11b0:	0e058e63          	beqz	a1,12ac <_free_r+0xfc>
    11b4:	ffc5a783          	lw	a5,-4(a1)
    11b8:	fe010113          	addi	sp,sp,-32
    11bc:	00812c23          	sw	s0,24(sp)
    11c0:	00112e23          	sw	ra,28(sp)
    11c4:	ffc58413          	addi	s0,a1,-4
    11c8:	0007d463          	bgez	a5,11d0 <_free_r+0x20>
    11cc:	00f40433          	add	s0,s0,a5
    11d0:	00a12623          	sw	a0,12(sp)
    11d4:	330000ef          	jal	ra,1504 <__malloc_lock>
    11d8:	1ffff717          	auipc	a4,0x1ffff
    11dc:	ff470713          	addi	a4,a4,-12 # 200001cc <__malloc_free_list>
    11e0:	00072783          	lw	a5,0(a4)
    11e4:	00c12503          	lw	a0,12(sp)
    11e8:	00079e63          	bnez	a5,1204 <_free_r+0x54>
    11ec:	00042223          	sw	zero,4(s0)
    11f0:	00872023          	sw	s0,0(a4)
    11f4:	01812403          	lw	s0,24(sp)
    11f8:	01c12083          	lw	ra,28(sp)
    11fc:	02010113          	addi	sp,sp,32
    1200:	3100006f          	j	1510 <__malloc_unlock>
    1204:	02f47463          	bgeu	s0,a5,122c <_free_r+0x7c>
    1208:	00042603          	lw	a2,0(s0)
    120c:	00c406b3          	add	a3,s0,a2
    1210:	00d79a63          	bne	a5,a3,1224 <_free_r+0x74>
    1214:	0007a683          	lw	a3,0(a5)
    1218:	0047a783          	lw	a5,4(a5)
    121c:	00c686b3          	add	a3,a3,a2
    1220:	00d42023          	sw	a3,0(s0)
    1224:	00f42223          	sw	a5,4(s0)
    1228:	fc9ff06f          	j	11f0 <_free_r+0x40>
    122c:	00078713          	mv	a4,a5
    1230:	0047a783          	lw	a5,4(a5)
    1234:	00078463          	beqz	a5,123c <_free_r+0x8c>
    1238:	fef47ae3          	bgeu	s0,a5,122c <_free_r+0x7c>
    123c:	00072683          	lw	a3,0(a4)
    1240:	00d70633          	add	a2,a4,a3
    1244:	02861863          	bne	a2,s0,1274 <_free_r+0xc4>
    1248:	00042603          	lw	a2,0(s0)
    124c:	00c686b3          	add	a3,a3,a2
    1250:	00d72023          	sw	a3,0(a4)
    1254:	00d70633          	add	a2,a4,a3
    1258:	f8c79ee3          	bne	a5,a2,11f4 <_free_r+0x44>
    125c:	0007a603          	lw	a2,0(a5)
    1260:	0047a783          	lw	a5,4(a5)
    1264:	00d606b3          	add	a3,a2,a3
    1268:	00d72023          	sw	a3,0(a4)
    126c:	00f72223          	sw	a5,4(a4)
    1270:	f85ff06f          	j	11f4 <_free_r+0x44>
    1274:	00c47863          	bgeu	s0,a2,1284 <_free_r+0xd4>
    1278:	00c00793          	li	a5,12
    127c:	00f52023          	sw	a5,0(a0)
    1280:	f75ff06f          	j	11f4 <_free_r+0x44>
    1284:	00042603          	lw	a2,0(s0)
    1288:	00c406b3          	add	a3,s0,a2
    128c:	00d79a63          	bne	a5,a3,12a0 <_free_r+0xf0>
    1290:	0007a683          	lw	a3,0(a5)
    1294:	0047a783          	lw	a5,4(a5)
    1298:	00c686b3          	add	a3,a3,a2
    129c:	00d42023          	sw	a3,0(s0)
    12a0:	00f42223          	sw	a5,4(s0)
    12a4:	00872223          	sw	s0,4(a4)
    12a8:	f4dff06f          	j	11f4 <_free_r+0x44>
    12ac:	00008067          	ret

000012b0 <sbrk_aligned>:
    12b0:	ff010113          	addi	sp,sp,-16
    12b4:	01212023          	sw	s2,0(sp)
    12b8:	1ffff917          	auipc	s2,0x1ffff
    12bc:	f1090913          	addi	s2,s2,-240 # 200001c8 <__malloc_sbrk_start>
    12c0:	00092783          	lw	a5,0(s2)
    12c4:	00812423          	sw	s0,8(sp)
    12c8:	00912223          	sw	s1,4(sp)
    12cc:	00112623          	sw	ra,12(sp)
    12d0:	00050493          	mv	s1,a0
    12d4:	00058413          	mv	s0,a1
    12d8:	00079863          	bnez	a5,12e8 <sbrk_aligned+0x38>
    12dc:	00000593          	li	a1,0
    12e0:	5d5010ef          	jal	ra,30b4 <_sbrk_r>
    12e4:	00a92023          	sw	a0,0(s2)
    12e8:	00040593          	mv	a1,s0
    12ec:	00048513          	mv	a0,s1
    12f0:	5c5010ef          	jal	ra,30b4 <_sbrk_r>
    12f4:	fff00913          	li	s2,-1
    12f8:	03251263          	bne	a0,s2,131c <sbrk_aligned+0x6c>
    12fc:	fff00413          	li	s0,-1
    1300:	00c12083          	lw	ra,12(sp)
    1304:	00040513          	mv	a0,s0
    1308:	00812403          	lw	s0,8(sp)
    130c:	00412483          	lw	s1,4(sp)
    1310:	00012903          	lw	s2,0(sp)
    1314:	01010113          	addi	sp,sp,16
    1318:	00008067          	ret
    131c:	00350413          	addi	s0,a0,3
    1320:	ffc47413          	andi	s0,s0,-4
    1324:	fc850ee3          	beq	a0,s0,1300 <sbrk_aligned+0x50>
    1328:	40a405b3          	sub	a1,s0,a0
    132c:	00048513          	mv	a0,s1
    1330:	585010ef          	jal	ra,30b4 <_sbrk_r>
    1334:	fd2516e3          	bne	a0,s2,1300 <sbrk_aligned+0x50>
    1338:	fc5ff06f          	j	12fc <sbrk_aligned+0x4c>

0000133c <_malloc_r>:
    133c:	fe010113          	addi	sp,sp,-32
    1340:	00912a23          	sw	s1,20(sp)
    1344:	00358493          	addi	s1,a1,3
    1348:	ffc4f493          	andi	s1,s1,-4
    134c:	01212823          	sw	s2,16(sp)
    1350:	00112e23          	sw	ra,28(sp)
    1354:	00812c23          	sw	s0,24(sp)
    1358:	01312623          	sw	s3,12(sp)
    135c:	01412423          	sw	s4,8(sp)
    1360:	00848493          	addi	s1,s1,8
    1364:	00c00793          	li	a5,12
    1368:	00050913          	mv	s2,a0
    136c:	0af4f463          	bgeu	s1,a5,1414 <_malloc_r+0xd8>
    1370:	00078493          	mv	s1,a5
    1374:	0ab4e263          	bltu	s1,a1,1418 <_malloc_r+0xdc>
    1378:	00090513          	mv	a0,s2
    137c:	188000ef          	jal	ra,1504 <__malloc_lock>
    1380:	1ffff997          	auipc	s3,0x1ffff
    1384:	e4c98993          	addi	s3,s3,-436 # 200001cc <__malloc_free_list>
    1388:	0009a783          	lw	a5,0(s3)
    138c:	00078413          	mv	s0,a5
    1390:	0a041863          	bnez	s0,1440 <_malloc_r+0x104>
    1394:	00048593          	mv	a1,s1
    1398:	00090513          	mv	a0,s2
    139c:	f15ff0ef          	jal	ra,12b0 <sbrk_aligned>
    13a0:	fff00793          	li	a5,-1
    13a4:	00050413          	mv	s0,a0
    13a8:	14f51a63          	bne	a0,a5,14fc <_malloc_r+0x1c0>
    13ac:	0009a403          	lw	s0,0(s3)
    13b0:	00040793          	mv	a5,s0
    13b4:	10079a63          	bnez	a5,14c8 <_malloc_r+0x18c>
    13b8:	12040863          	beqz	s0,14e8 <_malloc_r+0x1ac>
    13bc:	00042a03          	lw	s4,0(s0)
    13c0:	00000593          	li	a1,0
    13c4:	00090513          	mv	a0,s2
    13c8:	01440a33          	add	s4,s0,s4
    13cc:	4e9010ef          	jal	ra,30b4 <_sbrk_r>
    13d0:	10aa1c63          	bne	s4,a0,14e8 <_malloc_r+0x1ac>
    13d4:	00042783          	lw	a5,0(s0)
    13d8:	00090513          	mv	a0,s2
    13dc:	40f484b3          	sub	s1,s1,a5
    13e0:	00048593          	mv	a1,s1
    13e4:	ecdff0ef          	jal	ra,12b0 <sbrk_aligned>
    13e8:	fff00793          	li	a5,-1
    13ec:	0ef50e63          	beq	a0,a5,14e8 <_malloc_r+0x1ac>
    13f0:	00042783          	lw	a5,0(s0)
    13f4:	009787b3          	add	a5,a5,s1
    13f8:	00f42023          	sw	a5,0(s0)
    13fc:	0009a783          	lw	a5,0(s3)
    1400:	0047a703          	lw	a4,4(a5)
    1404:	0c071863          	bnez	a4,14d4 <_malloc_r+0x198>
    1408:	1ffff797          	auipc	a5,0x1ffff
    140c:	dc07a223          	sw	zero,-572(a5) # 200001cc <__malloc_free_list>
    1410:	0600006f          	j	1470 <_malloc_r+0x134>
    1414:	f604d0e3          	bgez	s1,1374 <_malloc_r+0x38>
    1418:	00f92023          	sw	a5,0(s2)
    141c:	00000513          	li	a0,0
    1420:	01c12083          	lw	ra,28(sp)
    1424:	01812403          	lw	s0,24(sp)
    1428:	01412483          	lw	s1,20(sp)
    142c:	01012903          	lw	s2,16(sp)
    1430:	00c12983          	lw	s3,12(sp)
    1434:	00812a03          	lw	s4,8(sp)
    1438:	02010113          	addi	sp,sp,32
    143c:	00008067          	ret
    1440:	00042683          	lw	a3,0(s0)
    1444:	409686b3          	sub	a3,a3,s1
    1448:	0606ca63          	bltz	a3,14bc <_malloc_r+0x180>
    144c:	00b00713          	li	a4,11
    1450:	04d77a63          	bgeu	a4,a3,14a4 <_malloc_r+0x168>
    1454:	00942023          	sw	s1,0(s0)
    1458:	00940733          	add	a4,s0,s1
    145c:	04879063          	bne	a5,s0,149c <_malloc_r+0x160>
    1460:	00e9a023          	sw	a4,0(s3)
    1464:	00442783          	lw	a5,4(s0)
    1468:	00d72023          	sw	a3,0(a4)
    146c:	00f72223          	sw	a5,4(a4)
    1470:	00090513          	mv	a0,s2
    1474:	09c000ef          	jal	ra,1510 <__malloc_unlock>
    1478:	00b40513          	addi	a0,s0,11
    147c:	00440793          	addi	a5,s0,4
    1480:	ff857513          	andi	a0,a0,-8
    1484:	40f50733          	sub	a4,a0,a5
    1488:	f8f50ce3          	beq	a0,a5,1420 <_malloc_r+0xe4>
    148c:	00e40433          	add	s0,s0,a4
    1490:	40a787b3          	sub	a5,a5,a0
    1494:	00f42023          	sw	a5,0(s0)
    1498:	f89ff06f          	j	1420 <_malloc_r+0xe4>
    149c:	00e7a223          	sw	a4,4(a5)
    14a0:	fc5ff06f          	j	1464 <_malloc_r+0x128>
    14a4:	00442703          	lw	a4,4(s0)
    14a8:	00879663          	bne	a5,s0,14b4 <_malloc_r+0x178>
    14ac:	00e9a023          	sw	a4,0(s3)
    14b0:	fc1ff06f          	j	1470 <_malloc_r+0x134>
    14b4:	00e7a223          	sw	a4,4(a5)
    14b8:	fb9ff06f          	j	1470 <_malloc_r+0x134>
    14bc:	00040793          	mv	a5,s0
    14c0:	00442403          	lw	s0,4(s0)
    14c4:	ecdff06f          	j	1390 <_malloc_r+0x54>
    14c8:	00078413          	mv	s0,a5
    14cc:	0047a783          	lw	a5,4(a5)
    14d0:	ee5ff06f          	j	13b4 <_malloc_r+0x78>
    14d4:	00078713          	mv	a4,a5
    14d8:	0047a783          	lw	a5,4(a5)
    14dc:	fe879ce3          	bne	a5,s0,14d4 <_malloc_r+0x198>
    14e0:	00072223          	sw	zero,4(a4)
    14e4:	f8dff06f          	j	1470 <_malloc_r+0x134>
    14e8:	00c00793          	li	a5,12
    14ec:	00f92023          	sw	a5,0(s2)
    14f0:	00090513          	mv	a0,s2
    14f4:	01c000ef          	jal	ra,1510 <__malloc_unlock>
    14f8:	f25ff06f          	j	141c <_malloc_r+0xe0>
    14fc:	00952023          	sw	s1,0(a0)
    1500:	f71ff06f          	j	1470 <_malloc_r+0x134>

00001504 <__malloc_lock>:
    1504:	1ffff517          	auipc	a0,0x1ffff
    1508:	cb450513          	addi	a0,a0,-844 # 200001b8 <__lock___malloc_recursive_mutex>
    150c:	c89ff06f          	j	1194 <__retarget_lock_acquire_recursive>

00001510 <__malloc_unlock>:
    1510:	1ffff517          	auipc	a0,0x1ffff
    1514:	ca850513          	addi	a0,a0,-856 # 200001b8 <__lock___malloc_recursive_mutex>
    1518:	c95ff06f          	j	11ac <__retarget_lock_release_recursive>

0000151c <__sfputc_r>:
    151c:	00862783          	lw	a5,8(a2)
    1520:	fff78793          	addi	a5,a5,-1
    1524:	00f62423          	sw	a5,8(a2)
    1528:	0007dc63          	bgez	a5,1540 <__sfputc_r+0x24>
    152c:	01862703          	lw	a4,24(a2)
    1530:	00e7c663          	blt	a5,a4,153c <__sfputc_r+0x20>
    1534:	00a00793          	li	a5,10
    1538:	00f59463          	bne	a1,a5,1540 <__sfputc_r+0x24>
    153c:	a19ff06f          	j	f54 <__swbuf_r>
    1540:	00062783          	lw	a5,0(a2)
    1544:	00058513          	mv	a0,a1
    1548:	00178713          	addi	a4,a5,1
    154c:	00e62023          	sw	a4,0(a2)
    1550:	00b78023          	sb	a1,0(a5)
    1554:	00008067          	ret

00001558 <__sfputs_r>:
    1558:	fe010113          	addi	sp,sp,-32
    155c:	00812c23          	sw	s0,24(sp)
    1560:	00912a23          	sw	s1,20(sp)
    1564:	01212823          	sw	s2,16(sp)
    1568:	01312623          	sw	s3,12(sp)
    156c:	01412423          	sw	s4,8(sp)
    1570:	00112e23          	sw	ra,28(sp)
    1574:	00050913          	mv	s2,a0
    1578:	00058993          	mv	s3,a1
    157c:	00060413          	mv	s0,a2
    1580:	00d604b3          	add	s1,a2,a3
    1584:	fff00a13          	li	s4,-1
    1588:	00941663          	bne	s0,s1,1594 <__sfputs_r+0x3c>
    158c:	00000513          	li	a0,0
    1590:	01c0006f          	j	15ac <__sfputs_r+0x54>
    1594:	00044583          	lbu	a1,0(s0)
    1598:	00098613          	mv	a2,s3
    159c:	00090513          	mv	a0,s2
    15a0:	f7dff0ef          	jal	ra,151c <__sfputc_r>
    15a4:	00140413          	addi	s0,s0,1
    15a8:	ff4510e3          	bne	a0,s4,1588 <__sfputs_r+0x30>
    15ac:	01c12083          	lw	ra,28(sp)
    15b0:	01812403          	lw	s0,24(sp)
    15b4:	01412483          	lw	s1,20(sp)
    15b8:	01012903          	lw	s2,16(sp)
    15bc:	00c12983          	lw	s3,12(sp)
    15c0:	00812a03          	lw	s4,8(sp)
    15c4:	02010113          	addi	sp,sp,32
    15c8:	00008067          	ret

000015cc <__sprint_r>:
    15cc:	00862783          	lw	a5,8(a2)
    15d0:	ff010113          	addi	sp,sp,-16
    15d4:	00812423          	sw	s0,8(sp)
    15d8:	00112623          	sw	ra,12(sp)
    15dc:	00060413          	mv	s0,a2
    15e0:	02078063          	beqz	a5,1600 <__sprint_r+0x34>
    15e4:	00c010ef          	jal	ra,25f0 <__sfvwrite_r>
    15e8:	00042423          	sw	zero,8(s0)
    15ec:	00c12083          	lw	ra,12(sp)
    15f0:	00042223          	sw	zero,4(s0)
    15f4:	00812403          	lw	s0,8(sp)
    15f8:	01010113          	addi	sp,sp,16
    15fc:	00008067          	ret
    1600:	00000513          	li	a0,0
    1604:	fe9ff06f          	j	15ec <__sprint_r+0x20>

00001608 <_vfiprintf_r>:
    1608:	f6010113          	addi	sp,sp,-160
    160c:	08812c23          	sw	s0,152(sp)
    1610:	08912a23          	sw	s1,148(sp)
    1614:	09212823          	sw	s2,144(sp)
    1618:	09312623          	sw	s3,140(sp)
    161c:	08112e23          	sw	ra,156(sp)
    1620:	09412423          	sw	s4,136(sp)
    1624:	09512223          	sw	s5,132(sp)
    1628:	09612023          	sw	s6,128(sp)
    162c:	07712e23          	sw	s7,124(sp)
    1630:	07812c23          	sw	s8,120(sp)
    1634:	07912a23          	sw	s9,116(sp)
    1638:	00050993          	mv	s3,a0
    163c:	00058493          	mv	s1,a1
    1640:	00060913          	mv	s2,a2
    1644:	00068413          	mv	s0,a3
    1648:	00050863          	beqz	a0,1658 <_vfiprintf_r+0x50>
    164c:	02052783          	lw	a5,32(a0)
    1650:	00079463          	bnez	a5,1658 <_vfiprintf_r+0x50>
    1654:	6f9000ef          	jal	ra,254c <__sinit>
    1658:	0644a783          	lw	a5,100(s1)
    165c:	0017f793          	andi	a5,a5,1
    1660:	00079c63          	bnez	a5,1678 <_vfiprintf_r+0x70>
    1664:	00c4d783          	lhu	a5,12(s1)
    1668:	2007f793          	andi	a5,a5,512
    166c:	00079663          	bnez	a5,1678 <_vfiprintf_r+0x70>
    1670:	0584a503          	lw	a0,88(s1)
    1674:	b21ff0ef          	jal	ra,1194 <__retarget_lock_acquire_recursive>
    1678:	00c4d783          	lhu	a5,12(s1)
    167c:	0087f793          	andi	a5,a5,8
    1680:	00078663          	beqz	a5,168c <_vfiprintf_r+0x84>
    1684:	0104a783          	lw	a5,16(s1)
    1688:	06079863          	bnez	a5,16f8 <_vfiprintf_r+0xf0>
    168c:	00048593          	mv	a1,s1
    1690:	00098513          	mv	a0,s3
    1694:	9d5ff0ef          	jal	ra,1068 <__swsetup_r>
    1698:	06050063          	beqz	a0,16f8 <_vfiprintf_r+0xf0>
    169c:	0644a783          	lw	a5,100(s1)
    16a0:	0017f793          	andi	a5,a5,1
    16a4:	02078e63          	beqz	a5,16e0 <_vfiprintf_r+0xd8>
    16a8:	fff00513          	li	a0,-1
    16ac:	09c12083          	lw	ra,156(sp)
    16b0:	09812403          	lw	s0,152(sp)
    16b4:	09412483          	lw	s1,148(sp)
    16b8:	09012903          	lw	s2,144(sp)
    16bc:	08c12983          	lw	s3,140(sp)
    16c0:	08812a03          	lw	s4,136(sp)
    16c4:	08412a83          	lw	s5,132(sp)
    16c8:	08012b03          	lw	s6,128(sp)
    16cc:	07c12b83          	lw	s7,124(sp)
    16d0:	07812c03          	lw	s8,120(sp)
    16d4:	07412c83          	lw	s9,116(sp)
    16d8:	0a010113          	addi	sp,sp,160
    16dc:	00008067          	ret
    16e0:	00c4d783          	lhu	a5,12(s1)
    16e4:	2007f793          	andi	a5,a5,512
    16e8:	fc0790e3          	bnez	a5,16a8 <_vfiprintf_r+0xa0>
    16ec:	0584a503          	lw	a0,88(s1)
    16f0:	abdff0ef          	jal	ra,11ac <__retarget_lock_release_recursive>
    16f4:	fb5ff06f          	j	16a8 <_vfiprintf_r+0xa0>
    16f8:	02000793          	li	a5,32
    16fc:	02f104a3          	sb	a5,41(sp)
    1700:	03000793          	li	a5,48
    1704:	02012223          	sw	zero,36(sp)
    1708:	02f10523          	sb	a5,42(sp)
    170c:	00812623          	sw	s0,12(sp)
    1710:	02500b93          	li	s7,37
    1714:	fff00a93          	li	s5,-1
    1718:	00100c13          	li	s8,1
    171c:	00a00b13          	li	s6,10
    1720:	00090413          	mv	s0,s2
    1724:	00044783          	lbu	a5,0(s0)
    1728:	00078463          	beqz	a5,1730 <_vfiprintf_r+0x128>
    172c:	0d779a63          	bne	a5,s7,1800 <_vfiprintf_r+0x1f8>
    1730:	41240cb3          	sub	s9,s0,s2
    1734:	03240463          	beq	s0,s2,175c <_vfiprintf_r+0x154>
    1738:	000c8693          	mv	a3,s9
    173c:	00090613          	mv	a2,s2
    1740:	00048593          	mv	a1,s1
    1744:	00098513          	mv	a0,s3
    1748:	e11ff0ef          	jal	ra,1558 <__sfputs_r>
    174c:	25550863          	beq	a0,s5,199c <_vfiprintf_r+0x394>
    1750:	02412783          	lw	a5,36(sp)
    1754:	019787b3          	add	a5,a5,s9
    1758:	02f12223          	sw	a5,36(sp)
    175c:	00044783          	lbu	a5,0(s0)
    1760:	22078e63          	beqz	a5,199c <_vfiprintf_r+0x394>
    1764:	00140913          	addi	s2,s0,1
    1768:	00012823          	sw	zero,16(sp)
    176c:	00012e23          	sw	zero,28(sp)
    1770:	01512a23          	sw	s5,20(sp)
    1774:	00012c23          	sw	zero,24(sp)
    1778:	040109a3          	sb	zero,83(sp)
    177c:	06012423          	sw	zero,104(sp)
    1780:	00002c97          	auipc	s9,0x2
    1784:	e7cc8c93          	addi	s9,s9,-388 # 35fc <__errno+0x37c>
    1788:	00094583          	lbu	a1,0(s2)
    178c:	00500613          	li	a2,5
    1790:	00002517          	auipc	a0,0x2
    1794:	e6c50513          	addi	a0,a0,-404 # 35fc <__errno+0x37c>
    1798:	600010ef          	jal	ra,2d98 <memchr>
    179c:	01012703          	lw	a4,16(sp)
    17a0:	00050793          	mv	a5,a0
    17a4:	00190413          	addi	s0,s2,1
    17a8:	06051063          	bnez	a0,1808 <_vfiprintf_r+0x200>
    17ac:	01077793          	andi	a5,a4,16
    17b0:	00078663          	beqz	a5,17bc <_vfiprintf_r+0x1b4>
    17b4:	02000793          	li	a5,32
    17b8:	04f109a3          	sb	a5,83(sp)
    17bc:	00877793          	andi	a5,a4,8
    17c0:	00078663          	beqz	a5,17cc <_vfiprintf_r+0x1c4>
    17c4:	02b00793          	li	a5,43
    17c8:	04f109a3          	sb	a5,83(sp)
    17cc:	00094683          	lbu	a3,0(s2)
    17d0:	02a00793          	li	a5,42
    17d4:	04f68663          	beq	a3,a5,1820 <_vfiprintf_r+0x218>
    17d8:	01c12783          	lw	a5,28(sp)
    17dc:	00090413          	mv	s0,s2
    17e0:	00000693          	li	a3,0
    17e4:	00900613          	li	a2,9
    17e8:	00044703          	lbu	a4,0(s0)
    17ec:	00140593          	addi	a1,s0,1
    17f0:	fd070713          	addi	a4,a4,-48
    17f4:	08e67a63          	bgeu	a2,a4,1888 <_vfiprintf_r+0x280>
    17f8:	02069e63          	bnez	a3,1834 <_vfiprintf_r+0x22c>
    17fc:	0500006f          	j	184c <_vfiprintf_r+0x244>
    1800:	00140413          	addi	s0,s0,1
    1804:	f21ff06f          	j	1724 <_vfiprintf_r+0x11c>
    1808:	419787b3          	sub	a5,a5,s9
    180c:	00fc17b3          	sll	a5,s8,a5
    1810:	00e7e7b3          	or	a5,a5,a4
    1814:	00f12823          	sw	a5,16(sp)
    1818:	00040913          	mv	s2,s0
    181c:	f6dff06f          	j	1788 <_vfiprintf_r+0x180>
    1820:	00c12783          	lw	a5,12(sp)
    1824:	00478693          	addi	a3,a5,4
    1828:	0007a783          	lw	a5,0(a5)
    182c:	00d12623          	sw	a3,12(sp)
    1830:	0007c663          	bltz	a5,183c <_vfiprintf_r+0x234>
    1834:	00f12e23          	sw	a5,28(sp)
    1838:	0140006f          	j	184c <_vfiprintf_r+0x244>
    183c:	40f007b3          	neg	a5,a5
    1840:	00276713          	ori	a4,a4,2
    1844:	00f12e23          	sw	a5,28(sp)
    1848:	00e12823          	sw	a4,16(sp)
    184c:	00044703          	lbu	a4,0(s0)
    1850:	02e00793          	li	a5,46
    1854:	06f71863          	bne	a4,a5,18c4 <_vfiprintf_r+0x2bc>
    1858:	00144703          	lbu	a4,1(s0)
    185c:	02a00793          	li	a5,42
    1860:	02f71e63          	bne	a4,a5,189c <_vfiprintf_r+0x294>
    1864:	00c12783          	lw	a5,12(sp)
    1868:	00240413          	addi	s0,s0,2
    186c:	00478713          	addi	a4,a5,4
    1870:	0007a783          	lw	a5,0(a5)
    1874:	00e12623          	sw	a4,12(sp)
    1878:	0007d463          	bgez	a5,1880 <_vfiprintf_r+0x278>
    187c:	fff00793          	li	a5,-1
    1880:	00f12a23          	sw	a5,20(sp)
    1884:	0400006f          	j	18c4 <_vfiprintf_r+0x2bc>
    1888:	036787b3          	mul	a5,a5,s6
    188c:	00058413          	mv	s0,a1
    1890:	00100693          	li	a3,1
    1894:	00e787b3          	add	a5,a5,a4
    1898:	f51ff06f          	j	17e8 <_vfiprintf_r+0x1e0>
    189c:	00140413          	addi	s0,s0,1
    18a0:	00012a23          	sw	zero,20(sp)
    18a4:	00000693          	li	a3,0
    18a8:	00000793          	li	a5,0
    18ac:	00900613          	li	a2,9
    18b0:	00044703          	lbu	a4,0(s0)
    18b4:	00140593          	addi	a1,s0,1
    18b8:	fd070713          	addi	a4,a4,-48
    18bc:	08e67a63          	bgeu	a2,a4,1950 <_vfiprintf_r+0x348>
    18c0:	fc0690e3          	bnez	a3,1880 <_vfiprintf_r+0x278>
    18c4:	00044583          	lbu	a1,0(s0)
    18c8:	00300613          	li	a2,3
    18cc:	00002517          	auipc	a0,0x2
    18d0:	d3850513          	addi	a0,a0,-712 # 3604 <__errno+0x384>
    18d4:	4c4010ef          	jal	ra,2d98 <memchr>
    18d8:	02050463          	beqz	a0,1900 <_vfiprintf_r+0x2f8>
    18dc:	00002797          	auipc	a5,0x2
    18e0:	d2878793          	addi	a5,a5,-728 # 3604 <__errno+0x384>
    18e4:	40f50533          	sub	a0,a0,a5
    18e8:	01012783          	lw	a5,16(sp)
    18ec:	04000713          	li	a4,64
    18f0:	00a71733          	sll	a4,a4,a0
    18f4:	00e7e7b3          	or	a5,a5,a4
    18f8:	00140413          	addi	s0,s0,1
    18fc:	00f12823          	sw	a5,16(sp)
    1900:	00044583          	lbu	a1,0(s0)
    1904:	00600613          	li	a2,6
    1908:	00002517          	auipc	a0,0x2
    190c:	d0050513          	addi	a0,a0,-768 # 3608 <__errno+0x388>
    1910:	00140913          	addi	s2,s0,1
    1914:	02b10423          	sb	a1,40(sp)
    1918:	480010ef          	jal	ra,2d98 <memchr>
    191c:	0a050a63          	beqz	a0,19d0 <_vfiprintf_r+0x3c8>
    1920:	00000793          	li	a5,0
    1924:	04079863          	bnez	a5,1974 <_vfiprintf_r+0x36c>
    1928:	01012703          	lw	a4,16(sp)
    192c:	00c12783          	lw	a5,12(sp)
    1930:	10077713          	andi	a4,a4,256
    1934:	02070863          	beqz	a4,1964 <_vfiprintf_r+0x35c>
    1938:	00478793          	addi	a5,a5,4
    193c:	00f12623          	sw	a5,12(sp)
    1940:	02412783          	lw	a5,36(sp)
    1944:	014787b3          	add	a5,a5,s4
    1948:	02f12223          	sw	a5,36(sp)
    194c:	dd5ff06f          	j	1720 <_vfiprintf_r+0x118>
    1950:	036787b3          	mul	a5,a5,s6
    1954:	00058413          	mv	s0,a1
    1958:	00100693          	li	a3,1
    195c:	00e787b3          	add	a5,a5,a4
    1960:	f51ff06f          	j	18b0 <_vfiprintf_r+0x2a8>
    1964:	00778793          	addi	a5,a5,7
    1968:	ff87f793          	andi	a5,a5,-8
    196c:	00878793          	addi	a5,a5,8
    1970:	fcdff06f          	j	193c <_vfiprintf_r+0x334>
    1974:	00c10713          	addi	a4,sp,12
    1978:	00000697          	auipc	a3,0x0
    197c:	be068693          	addi	a3,a3,-1056 # 1558 <__sfputs_r>
    1980:	00048613          	mv	a2,s1
    1984:	01010593          	addi	a1,sp,16
    1988:	00098513          	mv	a0,s3
    198c:	00000097          	auipc	ra,0x0
    1990:	000000e7          	jalr	zero # 0 <_start>
    1994:	00050a13          	mv	s4,a0
    1998:	fb5514e3          	bne	a0,s5,1940 <_vfiprintf_r+0x338>
    199c:	0644a783          	lw	a5,100(s1)
    19a0:	0017f793          	andi	a5,a5,1
    19a4:	00079c63          	bnez	a5,19bc <_vfiprintf_r+0x3b4>
    19a8:	00c4d783          	lhu	a5,12(s1)
    19ac:	2007f793          	andi	a5,a5,512
    19b0:	00079663          	bnez	a5,19bc <_vfiprintf_r+0x3b4>
    19b4:	0584a503          	lw	a0,88(s1)
    19b8:	ff4ff0ef          	jal	ra,11ac <__retarget_lock_release_recursive>
    19bc:	00c4d783          	lhu	a5,12(s1)
    19c0:	0407f793          	andi	a5,a5,64
    19c4:	ce0792e3          	bnez	a5,16a8 <_vfiprintf_r+0xa0>
    19c8:	02412503          	lw	a0,36(sp)
    19cc:	ce1ff06f          	j	16ac <_vfiprintf_r+0xa4>
    19d0:	00c10713          	addi	a4,sp,12
    19d4:	00000697          	auipc	a3,0x0
    19d8:	b8468693          	addi	a3,a3,-1148 # 1558 <__sfputs_r>
    19dc:	00048613          	mv	a2,s1
    19e0:	01010593          	addi	a1,sp,16
    19e4:	00098513          	mv	a0,s3
    19e8:	1d4000ef          	jal	ra,1bbc <_printf_i>
    19ec:	fa9ff06f          	j	1994 <_vfiprintf_r+0x38c>

000019f0 <vfiprintf>:
    19f0:	00060693          	mv	a3,a2
    19f4:	00058613          	mv	a2,a1
    19f8:	00050593          	mv	a1,a0
    19fc:	1fffe517          	auipc	a0,0x1fffe
    1a00:	60c52503          	lw	a0,1548(a0) # 20000008 <_impure_ptr>
    1a04:	c05ff06f          	j	1608 <_vfiprintf_r>

00001a08 <_printf_common>:
    1a08:	fd010113          	addi	sp,sp,-48
    1a0c:	01512a23          	sw	s5,20(sp)
    1a10:	0105a783          	lw	a5,16(a1)
    1a14:	00070a93          	mv	s5,a4
    1a18:	0085a703          	lw	a4,8(a1)
    1a1c:	02812423          	sw	s0,40(sp)
    1a20:	03212023          	sw	s2,32(sp)
    1a24:	01312e23          	sw	s3,28(sp)
    1a28:	01412c23          	sw	s4,24(sp)
    1a2c:	02112623          	sw	ra,44(sp)
    1a30:	02912223          	sw	s1,36(sp)
    1a34:	01612823          	sw	s6,16(sp)
    1a38:	01712623          	sw	s7,12(sp)
    1a3c:	00050993          	mv	s3,a0
    1a40:	00058413          	mv	s0,a1
    1a44:	00060913          	mv	s2,a2
    1a48:	00068a13          	mv	s4,a3
    1a4c:	00e7d463          	bge	a5,a4,1a54 <_printf_common+0x4c>
    1a50:	00070793          	mv	a5,a4
    1a54:	00f92023          	sw	a5,0(s2)
    1a58:	04344703          	lbu	a4,67(s0)
    1a5c:	00070663          	beqz	a4,1a68 <_printf_common+0x60>
    1a60:	00178793          	addi	a5,a5,1
    1a64:	00f92023          	sw	a5,0(s2)
    1a68:	00042783          	lw	a5,0(s0)
    1a6c:	0207f793          	andi	a5,a5,32
    1a70:	00078863          	beqz	a5,1a80 <_printf_common+0x78>
    1a74:	00092783          	lw	a5,0(s2)
    1a78:	00278793          	addi	a5,a5,2
    1a7c:	00f92023          	sw	a5,0(s2)
    1a80:	00042483          	lw	s1,0(s0)
    1a84:	0064f493          	andi	s1,s1,6
    1a88:	00049e63          	bnez	s1,1aa4 <_printf_common+0x9c>
    1a8c:	01940b13          	addi	s6,s0,25
    1a90:	fff00b93          	li	s7,-1
    1a94:	00c42783          	lw	a5,12(s0)
    1a98:	00092703          	lw	a4,0(s2)
    1a9c:	40e787b3          	sub	a5,a5,a4
    1aa0:	08f4c463          	blt	s1,a5,1b28 <_printf_common+0x120>
    1aa4:	04344783          	lbu	a5,67(s0)
    1aa8:	00f036b3          	snez	a3,a5
    1aac:	00042783          	lw	a5,0(s0)
    1ab0:	0207f793          	andi	a5,a5,32
    1ab4:	0c079263          	bnez	a5,1b78 <_printf_common+0x170>
    1ab8:	04340613          	addi	a2,s0,67
    1abc:	000a0593          	mv	a1,s4
    1ac0:	00098513          	mv	a0,s3
    1ac4:	000a80e7          	jalr	s5
    1ac8:	fff00793          	li	a5,-1
    1acc:	06f50a63          	beq	a0,a5,1b40 <_printf_common+0x138>
    1ad0:	00042783          	lw	a5,0(s0)
    1ad4:	00400713          	li	a4,4
    1ad8:	00000493          	li	s1,0
    1adc:	0067f793          	andi	a5,a5,6
    1ae0:	00e79e63          	bne	a5,a4,1afc <_printf_common+0xf4>
    1ae4:	00092783          	lw	a5,0(s2)
    1ae8:	00c42483          	lw	s1,12(s0)
    1aec:	40f484b3          	sub	s1,s1,a5
    1af0:	fff4c793          	not	a5,s1
    1af4:	41f7d793          	srai	a5,a5,0x1f
    1af8:	00f4f4b3          	and	s1,s1,a5
    1afc:	00842783          	lw	a5,8(s0)
    1b00:	01042703          	lw	a4,16(s0)
    1b04:	00f75663          	bge	a4,a5,1b10 <_printf_common+0x108>
    1b08:	40e787b3          	sub	a5,a5,a4
    1b0c:	00f484b3          	add	s1,s1,a5
    1b10:	00000913          	li	s2,0
    1b14:	01a40413          	addi	s0,s0,26
    1b18:	fff00b13          	li	s6,-1
    1b1c:	09249063          	bne	s1,s2,1b9c <_printf_common+0x194>
    1b20:	00000513          	li	a0,0
    1b24:	0200006f          	j	1b44 <_printf_common+0x13c>
    1b28:	00100693          	li	a3,1
    1b2c:	000b0613          	mv	a2,s6
    1b30:	000a0593          	mv	a1,s4
    1b34:	00098513          	mv	a0,s3
    1b38:	000a80e7          	jalr	s5
    1b3c:	03751a63          	bne	a0,s7,1b70 <_printf_common+0x168>
    1b40:	fff00513          	li	a0,-1
    1b44:	02c12083          	lw	ra,44(sp)
    1b48:	02812403          	lw	s0,40(sp)
    1b4c:	02412483          	lw	s1,36(sp)
    1b50:	02012903          	lw	s2,32(sp)
    1b54:	01c12983          	lw	s3,28(sp)
    1b58:	01812a03          	lw	s4,24(sp)
    1b5c:	01412a83          	lw	s5,20(sp)
    1b60:	01012b03          	lw	s6,16(sp)
    1b64:	00c12b83          	lw	s7,12(sp)
    1b68:	03010113          	addi	sp,sp,48
    1b6c:	00008067          	ret
    1b70:	00148493          	addi	s1,s1,1
    1b74:	f21ff06f          	j	1a94 <_printf_common+0x8c>
    1b78:	00d40733          	add	a4,s0,a3
    1b7c:	03000613          	li	a2,48
    1b80:	04c701a3          	sb	a2,67(a4)
    1b84:	04544703          	lbu	a4,69(s0)
    1b88:	00168793          	addi	a5,a3,1
    1b8c:	00f407b3          	add	a5,s0,a5
    1b90:	00268693          	addi	a3,a3,2
    1b94:	04e781a3          	sb	a4,67(a5)
    1b98:	f21ff06f          	j	1ab8 <_printf_common+0xb0>
    1b9c:	00100693          	li	a3,1
    1ba0:	00040613          	mv	a2,s0
    1ba4:	000a0593          	mv	a1,s4
    1ba8:	00098513          	mv	a0,s3
    1bac:	000a80e7          	jalr	s5
    1bb0:	f96508e3          	beq	a0,s6,1b40 <_printf_common+0x138>
    1bb4:	00190913          	addi	s2,s2,1
    1bb8:	f65ff06f          	j	1b1c <_printf_common+0x114>

00001bbc <_printf_i>:
    1bbc:	fd010113          	addi	sp,sp,-48
    1bc0:	02812423          	sw	s0,40(sp)
    1bc4:	02912223          	sw	s1,36(sp)
    1bc8:	03212023          	sw	s2,32(sp)
    1bcc:	01312e23          	sw	s3,28(sp)
    1bd0:	02112623          	sw	ra,44(sp)
    1bd4:	01412c23          	sw	s4,24(sp)
    1bd8:	01512a23          	sw	s5,20(sp)
    1bdc:	01612823          	sw	s6,16(sp)
    1be0:	0185c803          	lbu	a6,24(a1)
    1be4:	07800793          	li	a5,120
    1be8:	00050493          	mv	s1,a0
    1bec:	00058413          	mv	s0,a1
    1bf0:	00060913          	mv	s2,a2
    1bf4:	00068993          	mv	s3,a3
    1bf8:	0307e263          	bltu	a5,a6,1c1c <_printf_i+0x60>
    1bfc:	06200793          	li	a5,98
    1c00:	04358693          	addi	a3,a1,67
    1c04:	0307e263          	bltu	a5,a6,1c28 <_printf_i+0x6c>
    1c08:	28080463          	beqz	a6,1e90 <_printf_i+0x2d4>
    1c0c:	05800793          	li	a5,88
    1c10:	00002617          	auipc	a2,0x2
    1c14:	a0060613          	addi	a2,a2,-1536 # 3610 <__errno+0x390>
    1c18:	1cf80c63          	beq	a6,a5,1df0 <_printf_i+0x234>
    1c1c:	04240a93          	addi	s5,s0,66
    1c20:	05040123          	sb	a6,66(s0)
    1c24:	0480006f          	j	1c6c <_printf_i+0xb0>
    1c28:	f9d80793          	addi	a5,a6,-99
    1c2c:	0ff7f793          	andi	a5,a5,255
    1c30:	01500613          	li	a2,21
    1c34:	fef664e3          	bltu	a2,a5,1c1c <_printf_i+0x60>
    1c38:	00002617          	auipc	a2,0x2
    1c3c:	a0060613          	addi	a2,a2,-1536 # 3638 <__errno+0x3b8>
    1c40:	00279793          	slli	a5,a5,0x2
    1c44:	00c787b3          	add	a5,a5,a2
    1c48:	0007a783          	lw	a5,0(a5)
    1c4c:	00c787b3          	add	a5,a5,a2
    1c50:	00078067          	jr	a5
    1c54:	00072783          	lw	a5,0(a4)
    1c58:	04258a93          	addi	s5,a1,66
    1c5c:	00478693          	addi	a3,a5,4
    1c60:	0007a783          	lw	a5,0(a5)
    1c64:	00d72023          	sw	a3,0(a4)
    1c68:	04f58123          	sb	a5,66(a1)
    1c6c:	00100793          	li	a5,1
    1c70:	25c0006f          	j	1ecc <_printf_i+0x310>
    1c74:	0005a783          	lw	a5,0(a1)
    1c78:	00072503          	lw	a0,0(a4)
    1c7c:	0807f613          	andi	a2,a5,128
    1c80:	00450593          	addi	a1,a0,4
    1c84:	02060663          	beqz	a2,1cb0 <_printf_i+0xf4>
    1c88:	00052783          	lw	a5,0(a0)
    1c8c:	00b72023          	sw	a1,0(a4)
    1c90:	0007d863          	bgez	a5,1ca0 <_printf_i+0xe4>
    1c94:	02d00713          	li	a4,45
    1c98:	40f007b3          	neg	a5,a5
    1c9c:	04e401a3          	sb	a4,67(s0)
    1ca0:	00002617          	auipc	a2,0x2
    1ca4:	97060613          	addi	a2,a2,-1680 # 3610 <__errno+0x390>
    1ca8:	00a00813          	li	a6,10
    1cac:	0640006f          	j	1d10 <_printf_i+0x154>
    1cb0:	0407f613          	andi	a2,a5,64
    1cb4:	00052783          	lw	a5,0(a0)
    1cb8:	00b72023          	sw	a1,0(a4)
    1cbc:	fc060ae3          	beqz	a2,1c90 <_printf_i+0xd4>
    1cc0:	01079793          	slli	a5,a5,0x10
    1cc4:	4107d793          	srai	a5,a5,0x10
    1cc8:	fc9ff06f          	j	1c90 <_printf_i+0xd4>
    1ccc:	0005a583          	lw	a1,0(a1)
    1cd0:	00072603          	lw	a2,0(a4)
    1cd4:	0805f513          	andi	a0,a1,128
    1cd8:	00062783          	lw	a5,0(a2)
    1cdc:	00460613          	addi	a2,a2,4
    1ce0:	00051a63          	bnez	a0,1cf4 <_printf_i+0x138>
    1ce4:	0405f593          	andi	a1,a1,64
    1ce8:	00058663          	beqz	a1,1cf4 <_printf_i+0x138>
    1cec:	01079793          	slli	a5,a5,0x10
    1cf0:	0107d793          	srli	a5,a5,0x10
    1cf4:	00c72023          	sw	a2,0(a4)
    1cf8:	06f00713          	li	a4,111
    1cfc:	00002617          	auipc	a2,0x2
    1d00:	91460613          	addi	a2,a2,-1772 # 3610 <__errno+0x390>
    1d04:	14e81463          	bne	a6,a4,1e4c <_printf_i+0x290>
    1d08:	00800813          	li	a6,8
    1d0c:	040401a3          	sb	zero,67(s0)
    1d10:	00442703          	lw	a4,4(s0)
    1d14:	00e42423          	sw	a4,8(s0)
    1d18:	00074e63          	bltz	a4,1d34 <_printf_i+0x178>
    1d1c:	00042583          	lw	a1,0(s0)
    1d20:	00e7e733          	or	a4,a5,a4
    1d24:	00068a93          	mv	s5,a3
    1d28:	ffb5f593          	andi	a1,a1,-5
    1d2c:	00b42023          	sw	a1,0(s0)
    1d30:	02070463          	beqz	a4,1d58 <_printf_i+0x19c>
    1d34:	00068a93          	mv	s5,a3
    1d38:	0307f733          	remu	a4,a5,a6
    1d3c:	fffa8a93          	addi	s5,s5,-1
    1d40:	00e60733          	add	a4,a2,a4
    1d44:	00074703          	lbu	a4,0(a4)
    1d48:	00ea8023          	sb	a4,0(s5)
    1d4c:	00078713          	mv	a4,a5
    1d50:	0307d7b3          	divu	a5,a5,a6
    1d54:	ff0772e3          	bgeu	a4,a6,1d38 <_printf_i+0x17c>
    1d58:	00800793          	li	a5,8
    1d5c:	02f81463          	bne	a6,a5,1d84 <_printf_i+0x1c8>
    1d60:	00042783          	lw	a5,0(s0)
    1d64:	0017f793          	andi	a5,a5,1
    1d68:	00078e63          	beqz	a5,1d84 <_printf_i+0x1c8>
    1d6c:	00442703          	lw	a4,4(s0)
    1d70:	01042783          	lw	a5,16(s0)
    1d74:	00e7c863          	blt	a5,a4,1d84 <_printf_i+0x1c8>
    1d78:	03000793          	li	a5,48
    1d7c:	fefa8fa3          	sb	a5,-1(s5)
    1d80:	fffa8a93          	addi	s5,s5,-1
    1d84:	415686b3          	sub	a3,a3,s5
    1d88:	00d42823          	sw	a3,16(s0)
    1d8c:	00098713          	mv	a4,s3
    1d90:	00090693          	mv	a3,s2
    1d94:	00c10613          	addi	a2,sp,12
    1d98:	00040593          	mv	a1,s0
    1d9c:	00048513          	mv	a0,s1
    1da0:	c69ff0ef          	jal	ra,1a08 <_printf_common>
    1da4:	fff00a13          	li	s4,-1
    1da8:	13451863          	bne	a0,s4,1ed8 <_printf_i+0x31c>
    1dac:	fff00513          	li	a0,-1
    1db0:	02c12083          	lw	ra,44(sp)
    1db4:	02812403          	lw	s0,40(sp)
    1db8:	02412483          	lw	s1,36(sp)
    1dbc:	02012903          	lw	s2,32(sp)
    1dc0:	01c12983          	lw	s3,28(sp)
    1dc4:	01812a03          	lw	s4,24(sp)
    1dc8:	01412a83          	lw	s5,20(sp)
    1dcc:	01012b03          	lw	s6,16(sp)
    1dd0:	03010113          	addi	sp,sp,48
    1dd4:	00008067          	ret
    1dd8:	0005a783          	lw	a5,0(a1)
    1ddc:	0207e793          	ori	a5,a5,32
    1de0:	00f5a023          	sw	a5,0(a1)
    1de4:	07800813          	li	a6,120
    1de8:	00002617          	auipc	a2,0x2
    1dec:	83c60613          	addi	a2,a2,-1988 # 3624 <__errno+0x3a4>
    1df0:	050402a3          	sb	a6,69(s0)
    1df4:	00042583          	lw	a1,0(s0)
    1df8:	00072503          	lw	a0,0(a4)
    1dfc:	0805f813          	andi	a6,a1,128
    1e00:	00052783          	lw	a5,0(a0)
    1e04:	00450513          	addi	a0,a0,4
    1e08:	00081a63          	bnez	a6,1e1c <_printf_i+0x260>
    1e0c:	0405f813          	andi	a6,a1,64
    1e10:	00080663          	beqz	a6,1e1c <_printf_i+0x260>
    1e14:	01079793          	slli	a5,a5,0x10
    1e18:	0107d793          	srli	a5,a5,0x10
    1e1c:	00a72023          	sw	a0,0(a4)
    1e20:	0015f713          	andi	a4,a1,1
    1e24:	00070663          	beqz	a4,1e30 <_printf_i+0x274>
    1e28:	0205e593          	ori	a1,a1,32
    1e2c:	00b42023          	sw	a1,0(s0)
    1e30:	00078663          	beqz	a5,1e3c <_printf_i+0x280>
    1e34:	01000813          	li	a6,16
    1e38:	ed5ff06f          	j	1d0c <_printf_i+0x150>
    1e3c:	00042703          	lw	a4,0(s0)
    1e40:	fdf77713          	andi	a4,a4,-33
    1e44:	00e42023          	sw	a4,0(s0)
    1e48:	fedff06f          	j	1e34 <_printf_i+0x278>
    1e4c:	00a00813          	li	a6,10
    1e50:	ebdff06f          	j	1d0c <_printf_i+0x150>
    1e54:	0005a603          	lw	a2,0(a1)
    1e58:	00072783          	lw	a5,0(a4)
    1e5c:	0145a583          	lw	a1,20(a1)
    1e60:	08067813          	andi	a6,a2,128
    1e64:	00478513          	addi	a0,a5,4
    1e68:	00080a63          	beqz	a6,1e7c <_printf_i+0x2c0>
    1e6c:	00a72023          	sw	a0,0(a4)
    1e70:	0007a783          	lw	a5,0(a5)
    1e74:	00b7a023          	sw	a1,0(a5)
    1e78:	0180006f          	j	1e90 <_printf_i+0x2d4>
    1e7c:	00a72023          	sw	a0,0(a4)
    1e80:	04067613          	andi	a2,a2,64
    1e84:	0007a783          	lw	a5,0(a5)
    1e88:	fe0606e3          	beqz	a2,1e74 <_printf_i+0x2b8>
    1e8c:	00b79023          	sh	a1,0(a5)
    1e90:	00042823          	sw	zero,16(s0)
    1e94:	00068a93          	mv	s5,a3
    1e98:	ef5ff06f          	j	1d8c <_printf_i+0x1d0>
    1e9c:	00072783          	lw	a5,0(a4)
    1ea0:	0045a603          	lw	a2,4(a1)
    1ea4:	00000593          	li	a1,0
    1ea8:	00478693          	addi	a3,a5,4
    1eac:	00d72023          	sw	a3,0(a4)
    1eb0:	0007aa83          	lw	s5,0(a5)
    1eb4:	000a8513          	mv	a0,s5
    1eb8:	6e1000ef          	jal	ra,2d98 <memchr>
    1ebc:	00050663          	beqz	a0,1ec8 <_printf_i+0x30c>
    1ec0:	41550533          	sub	a0,a0,s5
    1ec4:	00a42223          	sw	a0,4(s0)
    1ec8:	00442783          	lw	a5,4(s0)
    1ecc:	00f42823          	sw	a5,16(s0)
    1ed0:	040401a3          	sb	zero,67(s0)
    1ed4:	eb9ff06f          	j	1d8c <_printf_i+0x1d0>
    1ed8:	01042683          	lw	a3,16(s0)
    1edc:	000a8613          	mv	a2,s5
    1ee0:	00090593          	mv	a1,s2
    1ee4:	00048513          	mv	a0,s1
    1ee8:	000980e7          	jalr	s3
    1eec:	ed4500e3          	beq	a0,s4,1dac <_printf_i+0x1f0>
    1ef0:	00042783          	lw	a5,0(s0)
    1ef4:	0027f793          	andi	a5,a5,2
    1ef8:	04079463          	bnez	a5,1f40 <_printf_i+0x384>
    1efc:	00c12783          	lw	a5,12(sp)
    1f00:	00c42503          	lw	a0,12(s0)
    1f04:	eaf556e3          	bge	a0,a5,1db0 <_printf_i+0x1f4>
    1f08:	00078513          	mv	a0,a5
    1f0c:	ea5ff06f          	j	1db0 <_printf_i+0x1f4>
    1f10:	00100693          	li	a3,1
    1f14:	000b0613          	mv	a2,s6
    1f18:	00090593          	mv	a1,s2
    1f1c:	00048513          	mv	a0,s1
    1f20:	000980e7          	jalr	s3
    1f24:	e94504e3          	beq	a0,s4,1dac <_printf_i+0x1f0>
    1f28:	001a8a93          	addi	s5,s5,1
    1f2c:	00c42783          	lw	a5,12(s0)
    1f30:	00c12703          	lw	a4,12(sp)
    1f34:	40e787b3          	sub	a5,a5,a4
    1f38:	fcfacce3          	blt	s5,a5,1f10 <_printf_i+0x354>
    1f3c:	fc1ff06f          	j	1efc <_printf_i+0x340>
    1f40:	00000a93          	li	s5,0
    1f44:	01940b13          	addi	s6,s0,25
    1f48:	fe5ff06f          	j	1f2c <_printf_i+0x370>

00001f4c <__sflush_r>:
    1f4c:	00c59783          	lh	a5,12(a1)
    1f50:	fe010113          	addi	sp,sp,-32
    1f54:	00812c23          	sw	s0,24(sp)
    1f58:	00912a23          	sw	s1,20(sp)
    1f5c:	00112e23          	sw	ra,28(sp)
    1f60:	01212823          	sw	s2,16(sp)
    1f64:	01312623          	sw	s3,12(sp)
    1f68:	0087f713          	andi	a4,a5,8
    1f6c:	00050493          	mv	s1,a0
    1f70:	00058413          	mv	s0,a1
    1f74:	12071263          	bnez	a4,2098 <__sflush_r+0x14c>
    1f78:	0045a703          	lw	a4,4(a1)
    1f7c:	00e04663          	bgtz	a4,1f88 <__sflush_r+0x3c>
    1f80:	0405a703          	lw	a4,64(a1)
    1f84:	10e05663          	blez	a4,2090 <__sflush_r+0x144>
    1f88:	02c42703          	lw	a4,44(s0)
    1f8c:	10070263          	beqz	a4,2090 <__sflush_r+0x144>
    1f90:	0004a903          	lw	s2,0(s1)
    1f94:	01379693          	slli	a3,a5,0x13
    1f98:	0004a023          	sw	zero,0(s1)
    1f9c:	0a06dc63          	bgez	a3,2054 <__sflush_r+0x108>
    1fa0:	05442603          	lw	a2,84(s0)
    1fa4:	00c45783          	lhu	a5,12(s0)
    1fa8:	0047f793          	andi	a5,a5,4
    1fac:	00078e63          	beqz	a5,1fc8 <__sflush_r+0x7c>
    1fb0:	00442783          	lw	a5,4(s0)
    1fb4:	40f60633          	sub	a2,a2,a5
    1fb8:	03442783          	lw	a5,52(s0)
    1fbc:	00078663          	beqz	a5,1fc8 <__sflush_r+0x7c>
    1fc0:	04042783          	lw	a5,64(s0)
    1fc4:	40f60633          	sub	a2,a2,a5
    1fc8:	02c42783          	lw	a5,44(s0)
    1fcc:	02042583          	lw	a1,32(s0)
    1fd0:	00000693          	li	a3,0
    1fd4:	00048513          	mv	a0,s1
    1fd8:	000780e7          	jalr	a5
    1fdc:	fff00713          	li	a4,-1
    1fe0:	00c41783          	lh	a5,12(s0)
    1fe4:	02e51263          	bne	a0,a4,2008 <__sflush_r+0xbc>
    1fe8:	0004a683          	lw	a3,0(s1)
    1fec:	01d00713          	li	a4,29
    1ff0:	0ed76a63          	bltu	a4,a3,20e4 <__sflush_r+0x198>
    1ff4:	20400737          	lui	a4,0x20400
    1ff8:	00170713          	addi	a4,a4,1 # 20400001 <_estack+0x3e0001>
    1ffc:	00d75733          	srl	a4,a4,a3
    2000:	00177713          	andi	a4,a4,1
    2004:	0e070063          	beqz	a4,20e4 <__sflush_r+0x198>
    2008:	01042703          	lw	a4,16(s0)
    200c:	00042223          	sw	zero,4(s0)
    2010:	00e42023          	sw	a4,0(s0)
    2014:	01379713          	slli	a4,a5,0x13
    2018:	00075c63          	bgez	a4,2030 <__sflush_r+0xe4>
    201c:	fff00793          	li	a5,-1
    2020:	00f51663          	bne	a0,a5,202c <__sflush_r+0xe0>
    2024:	0004a783          	lw	a5,0(s1)
    2028:	00079463          	bnez	a5,2030 <__sflush_r+0xe4>
    202c:	04a42a23          	sw	a0,84(s0)
    2030:	03442583          	lw	a1,52(s0)
    2034:	0124a023          	sw	s2,0(s1)
    2038:	04058c63          	beqz	a1,2090 <__sflush_r+0x144>
    203c:	04440793          	addi	a5,s0,68
    2040:	00f58663          	beq	a1,a5,204c <__sflush_r+0x100>
    2044:	00048513          	mv	a0,s1
    2048:	968ff0ef          	jal	ra,11b0 <_free_r>
    204c:	02042a23          	sw	zero,52(s0)
    2050:	0400006f          	j	2090 <__sflush_r+0x144>
    2054:	02042583          	lw	a1,32(s0)
    2058:	00000613          	li	a2,0
    205c:	00100693          	li	a3,1
    2060:	00048513          	mv	a0,s1
    2064:	000700e7          	jalr	a4
    2068:	fff00793          	li	a5,-1
    206c:	00050613          	mv	a2,a0
    2070:	f2f51ae3          	bne	a0,a5,1fa4 <__sflush_r+0x58>
    2074:	0004a783          	lw	a5,0(s1)
    2078:	f20786e3          	beqz	a5,1fa4 <__sflush_r+0x58>
    207c:	01d00713          	li	a4,29
    2080:	00e78663          	beq	a5,a4,208c <__sflush_r+0x140>
    2084:	01600713          	li	a4,22
    2088:	04e79c63          	bne	a5,a4,20e0 <__sflush_r+0x194>
    208c:	0124a023          	sw	s2,0(s1)
    2090:	00000513          	li	a0,0
    2094:	05c0006f          	j	20f0 <__sflush_r+0x1a4>
    2098:	0105a983          	lw	s3,16(a1)
    209c:	fe098ae3          	beqz	s3,2090 <__sflush_r+0x144>
    20a0:	0005a903          	lw	s2,0(a1)
    20a4:	0037f793          	andi	a5,a5,3
    20a8:	0135a023          	sw	s3,0(a1)
    20ac:	41390933          	sub	s2,s2,s3
    20b0:	00000713          	li	a4,0
    20b4:	00079463          	bnez	a5,20bc <__sflush_r+0x170>
    20b8:	0145a703          	lw	a4,20(a1)
    20bc:	00e42423          	sw	a4,8(s0)
    20c0:	fd2058e3          	blez	s2,2090 <__sflush_r+0x144>
    20c4:	02842783          	lw	a5,40(s0)
    20c8:	02042583          	lw	a1,32(s0)
    20cc:	00090693          	mv	a3,s2
    20d0:	00098613          	mv	a2,s3
    20d4:	00048513          	mv	a0,s1
    20d8:	000780e7          	jalr	a5
    20dc:	02a04863          	bgtz	a0,210c <__sflush_r+0x1c0>
    20e0:	00c41783          	lh	a5,12(s0)
    20e4:	0407e793          	ori	a5,a5,64
    20e8:	00f41623          	sh	a5,12(s0)
    20ec:	fff00513          	li	a0,-1
    20f0:	01c12083          	lw	ra,28(sp)
    20f4:	01812403          	lw	s0,24(sp)
    20f8:	01412483          	lw	s1,20(sp)
    20fc:	01012903          	lw	s2,16(sp)
    2100:	00c12983          	lw	s3,12(sp)
    2104:	02010113          	addi	sp,sp,32
    2108:	00008067          	ret
    210c:	00a989b3          	add	s3,s3,a0
    2110:	40a90933          	sub	s2,s2,a0
    2114:	fadff06f          	j	20c0 <__sflush_r+0x174>

00002118 <_fflush_r>:
    2118:	0105a783          	lw	a5,16(a1)
    211c:	ff010113          	addi	sp,sp,-16
    2120:	00112623          	sw	ra,12(sp)
    2124:	00812423          	sw	s0,8(sp)
    2128:	00912223          	sw	s1,4(sp)
    212c:	02079063          	bnez	a5,214c <_fflush_r+0x34>
    2130:	00000493          	li	s1,0
    2134:	00c12083          	lw	ra,12(sp)
    2138:	00812403          	lw	s0,8(sp)
    213c:	00048513          	mv	a0,s1
    2140:	00412483          	lw	s1,4(sp)
    2144:	01010113          	addi	sp,sp,16
    2148:	00008067          	ret
    214c:	00050493          	mv	s1,a0
    2150:	00058413          	mv	s0,a1
    2154:	00050863          	beqz	a0,2164 <_fflush_r+0x4c>
    2158:	02052783          	lw	a5,32(a0)
    215c:	00079463          	bnez	a5,2164 <_fflush_r+0x4c>
    2160:	3ec000ef          	jal	ra,254c <__sinit>
    2164:	00c41783          	lh	a5,12(s0)
    2168:	fc0784e3          	beqz	a5,2130 <_fflush_r+0x18>
    216c:	06442703          	lw	a4,100(s0)
    2170:	00177713          	andi	a4,a4,1
    2174:	00071a63          	bnez	a4,2188 <_fflush_r+0x70>
    2178:	2007f793          	andi	a5,a5,512
    217c:	00079663          	bnez	a5,2188 <_fflush_r+0x70>
    2180:	05842503          	lw	a0,88(s0)
    2184:	810ff0ef          	jal	ra,1194 <__retarget_lock_acquire_recursive>
    2188:	00048513          	mv	a0,s1
    218c:	00040593          	mv	a1,s0
    2190:	dbdff0ef          	jal	ra,1f4c <__sflush_r>
    2194:	06442783          	lw	a5,100(s0)
    2198:	00050493          	mv	s1,a0
    219c:	0017f793          	andi	a5,a5,1
    21a0:	f8079ae3          	bnez	a5,2134 <_fflush_r+0x1c>
    21a4:	00c45783          	lhu	a5,12(s0)
    21a8:	2007f793          	andi	a5,a5,512
    21ac:	f80794e3          	bnez	a5,2134 <_fflush_r+0x1c>
    21b0:	05842503          	lw	a0,88(s0)
    21b4:	ff9fe0ef          	jal	ra,11ac <__retarget_lock_release_recursive>
    21b8:	f7dff06f          	j	2134 <_fflush_r+0x1c>

000021bc <fflush>:
    21bc:	00050593          	mv	a1,a0
    21c0:	02051063          	bnez	a0,21e0 <fflush+0x24>
    21c4:	1fffe617          	auipc	a2,0x1fffe
    21c8:	e9460613          	addi	a2,a2,-364 # 20000058 <__sglue>
    21cc:	00000597          	auipc	a1,0x0
    21d0:	f4c58593          	addi	a1,a1,-180 # 2118 <_fflush_r>
    21d4:	1fffe517          	auipc	a0,0x1fffe
    21d8:	e3850513          	addi	a0,a0,-456 # 2000000c <_impure_data>
    21dc:	0710006f          	j	2a4c <_fwalk_sglue>
    21e0:	1fffe517          	auipc	a0,0x1fffe
    21e4:	e2852503          	lw	a0,-472(a0) # 20000008 <_impure_ptr>
    21e8:	f31ff06f          	j	2118 <_fflush_r>

000021ec <std>:
    21ec:	ff010113          	addi	sp,sp,-16
    21f0:	00812423          	sw	s0,8(sp)
    21f4:	00112623          	sw	ra,12(sp)
    21f8:	00050413          	mv	s0,a0
    21fc:	00b51623          	sh	a1,12(a0)
    2200:	00c51723          	sh	a2,14(a0)
    2204:	00052023          	sw	zero,0(a0)
    2208:	00052223          	sw	zero,4(a0)
    220c:	00052423          	sw	zero,8(a0)
    2210:	06052223          	sw	zero,100(a0)
    2214:	00052823          	sw	zero,16(a0)
    2218:	00052a23          	sw	zero,20(a0)
    221c:	00052c23          	sw	zero,24(a0)
    2220:	00800613          	li	a2,8
    2224:	00000593          	li	a1,0
    2228:	05c50513          	addi	a0,a0,92
    222c:	941fe0ef          	jal	ra,b6c <memset>
    2230:	00001797          	auipc	a5,0x1
    2234:	a2c78793          	addi	a5,a5,-1492 # 2c5c <__sread>
    2238:	02f42223          	sw	a5,36(s0)
    223c:	00001797          	auipc	a5,0x1
    2240:	a7878793          	addi	a5,a5,-1416 # 2cb4 <__swrite>
    2244:	02f42423          	sw	a5,40(s0)
    2248:	00001797          	auipc	a5,0x1
    224c:	af078793          	addi	a5,a5,-1296 # 2d38 <__sseek>
    2250:	02f42623          	sw	a5,44(s0)
    2254:	00001797          	auipc	a5,0x1
    2258:	b3c78793          	addi	a5,a5,-1220 # 2d90 <__sclose>
    225c:	02f42823          	sw	a5,48(s0)
    2260:	02842023          	sw	s0,32(s0)
    2264:	1fffe797          	auipc	a5,0x1fffe
    2268:	e0078793          	addi	a5,a5,-512 # 20000064 <__sf>
    226c:	00f40e63          	beq	s0,a5,2288 <std+0x9c>
    2270:	1fffe797          	auipc	a5,0x1fffe
    2274:	e5c78793          	addi	a5,a5,-420 # 200000cc <__sf+0x68>
    2278:	00f40863          	beq	s0,a5,2288 <std+0x9c>
    227c:	1fffe797          	auipc	a5,0x1fffe
    2280:	eb878793          	addi	a5,a5,-328 # 20000134 <__sf+0xd0>
    2284:	00f41c63          	bne	s0,a5,229c <std+0xb0>
    2288:	05840513          	addi	a0,s0,88
    228c:	00812403          	lw	s0,8(sp)
    2290:	00c12083          	lw	ra,12(sp)
    2294:	01010113          	addi	sp,sp,16
    2298:	eedfe06f          	j	1184 <__retarget_lock_init_recursive>
    229c:	00c12083          	lw	ra,12(sp)
    22a0:	00812403          	lw	s0,8(sp)
    22a4:	01010113          	addi	sp,sp,16
    22a8:	00008067          	ret

000022ac <stdio_exit_handler>:
    22ac:	1fffe617          	auipc	a2,0x1fffe
    22b0:	dac60613          	addi	a2,a2,-596 # 20000058 <__sglue>
    22b4:	00000597          	auipc	a1,0x0
    22b8:	e6458593          	addi	a1,a1,-412 # 2118 <_fflush_r>
    22bc:	1fffe517          	auipc	a0,0x1fffe
    22c0:	d5050513          	addi	a0,a0,-688 # 2000000c <_impure_data>
    22c4:	7880006f          	j	2a4c <_fwalk_sglue>

000022c8 <cleanup_stdio>:
    22c8:	00452583          	lw	a1,4(a0)
    22cc:	ff010113          	addi	sp,sp,-16
    22d0:	00812423          	sw	s0,8(sp)
    22d4:	00112623          	sw	ra,12(sp)
    22d8:	1fffe797          	auipc	a5,0x1fffe
    22dc:	d8c78793          	addi	a5,a5,-628 # 20000064 <__sf>
    22e0:	00050413          	mv	s0,a0
    22e4:	00f58463          	beq	a1,a5,22ec <cleanup_stdio+0x24>
    22e8:	e31ff0ef          	jal	ra,2118 <_fflush_r>
    22ec:	00842583          	lw	a1,8(s0)
    22f0:	1fffe797          	auipc	a5,0x1fffe
    22f4:	ddc78793          	addi	a5,a5,-548 # 200000cc <__sf+0x68>
    22f8:	00f58663          	beq	a1,a5,2304 <cleanup_stdio+0x3c>
    22fc:	00040513          	mv	a0,s0
    2300:	e19ff0ef          	jal	ra,2118 <_fflush_r>
    2304:	00c42583          	lw	a1,12(s0)
    2308:	1fffe797          	auipc	a5,0x1fffe
    230c:	e2c78793          	addi	a5,a5,-468 # 20000134 <__sf+0xd0>
    2310:	00f58c63          	beq	a1,a5,2328 <cleanup_stdio+0x60>
    2314:	00040513          	mv	a0,s0
    2318:	00812403          	lw	s0,8(sp)
    231c:	00c12083          	lw	ra,12(sp)
    2320:	01010113          	addi	sp,sp,16
    2324:	df5ff06f          	j	2118 <_fflush_r>
    2328:	00c12083          	lw	ra,12(sp)
    232c:	00812403          	lw	s0,8(sp)
    2330:	01010113          	addi	sp,sp,16
    2334:	00008067          	ret

00002338 <__fp_lock>:
    2338:	0645a783          	lw	a5,100(a1)
    233c:	0017f793          	andi	a5,a5,1
    2340:	02079863          	bnez	a5,2370 <__fp_lock+0x38>
    2344:	00c5d783          	lhu	a5,12(a1)
    2348:	2007f793          	andi	a5,a5,512
    234c:	02079263          	bnez	a5,2370 <__fp_lock+0x38>
    2350:	0585a503          	lw	a0,88(a1)
    2354:	ff010113          	addi	sp,sp,-16
    2358:	00112623          	sw	ra,12(sp)
    235c:	e39fe0ef          	jal	ra,1194 <__retarget_lock_acquire_recursive>
    2360:	00c12083          	lw	ra,12(sp)
    2364:	00000513          	li	a0,0
    2368:	01010113          	addi	sp,sp,16
    236c:	00008067          	ret
    2370:	00000513          	li	a0,0
    2374:	00008067          	ret

00002378 <__fp_unlock>:
    2378:	0645a783          	lw	a5,100(a1)
    237c:	0017f793          	andi	a5,a5,1
    2380:	02079863          	bnez	a5,23b0 <__fp_unlock+0x38>
    2384:	00c5d783          	lhu	a5,12(a1)
    2388:	2007f793          	andi	a5,a5,512
    238c:	02079263          	bnez	a5,23b0 <__fp_unlock+0x38>
    2390:	0585a503          	lw	a0,88(a1)
    2394:	ff010113          	addi	sp,sp,-16
    2398:	00112623          	sw	ra,12(sp)
    239c:	e11fe0ef          	jal	ra,11ac <__retarget_lock_release_recursive>
    23a0:	00c12083          	lw	ra,12(sp)
    23a4:	00000513          	li	a0,0
    23a8:	01010113          	addi	sp,sp,16
    23ac:	00008067          	ret
    23b0:	00000513          	li	a0,0
    23b4:	00008067          	ret

000023b8 <global_stdio_init.part.0>:
    23b8:	ff010113          	addi	sp,sp,-16
    23bc:	00000797          	auipc	a5,0x0
    23c0:	ef078793          	addi	a5,a5,-272 # 22ac <stdio_exit_handler>
    23c4:	00000613          	li	a2,0
    23c8:	00400593          	li	a1,4
    23cc:	1fffe517          	auipc	a0,0x1fffe
    23d0:	c9850513          	addi	a0,a0,-872 # 20000064 <__sf>
    23d4:	00112623          	sw	ra,12(sp)
    23d8:	1fffe717          	auipc	a4,0x1fffe
    23dc:	def72c23          	sw	a5,-520(a4) # 200001d0 <__stdio_exit_handler>
    23e0:	e0dff0ef          	jal	ra,21ec <std>
    23e4:	00100613          	li	a2,1
    23e8:	00900593          	li	a1,9
    23ec:	1fffe517          	auipc	a0,0x1fffe
    23f0:	ce050513          	addi	a0,a0,-800 # 200000cc <__sf+0x68>
    23f4:	df9ff0ef          	jal	ra,21ec <std>
    23f8:	00c12083          	lw	ra,12(sp)
    23fc:	00200613          	li	a2,2
    2400:	01200593          	li	a1,18
    2404:	1fffe517          	auipc	a0,0x1fffe
    2408:	d3050513          	addi	a0,a0,-720 # 20000134 <__sf+0xd0>
    240c:	01010113          	addi	sp,sp,16
    2410:	dddff06f          	j	21ec <std>

00002414 <__sfp_lock_acquire>:
    2414:	1fffe517          	auipc	a0,0x1fffe
    2418:	db050513          	addi	a0,a0,-592 # 200001c4 <__lock___sfp_recursive_mutex>
    241c:	d79fe06f          	j	1194 <__retarget_lock_acquire_recursive>

00002420 <__sfp_lock_release>:
    2420:	1fffe517          	auipc	a0,0x1fffe
    2424:	da450513          	addi	a0,a0,-604 # 200001c4 <__lock___sfp_recursive_mutex>
    2428:	d85fe06f          	j	11ac <__retarget_lock_release_recursive>

0000242c <__sfp>:
    242c:	ff010113          	addi	sp,sp,-16
    2430:	01212023          	sw	s2,0(sp)
    2434:	00112623          	sw	ra,12(sp)
    2438:	00812423          	sw	s0,8(sp)
    243c:	00912223          	sw	s1,4(sp)
    2440:	00050913          	mv	s2,a0
    2444:	fd1ff0ef          	jal	ra,2414 <__sfp_lock_acquire>
    2448:	1fffe797          	auipc	a5,0x1fffe
    244c:	d887a783          	lw	a5,-632(a5) # 200001d0 <__stdio_exit_handler>
    2450:	00079463          	bnez	a5,2458 <__sfp+0x2c>
    2454:	f65ff0ef          	jal	ra,23b8 <global_stdio_init.part.0>
    2458:	1fffe497          	auipc	s1,0x1fffe
    245c:	c0048493          	addi	s1,s1,-1024 # 20000058 <__sglue>
    2460:	0084a403          	lw	s0,8(s1)
    2464:	0044a783          	lw	a5,4(s1)
    2468:	fff78793          	addi	a5,a5,-1
    246c:	0207da63          	bgez	a5,24a0 <__sfp+0x74>
    2470:	0004a403          	lw	s0,0(s1)
    2474:	0c041863          	bnez	s0,2544 <__sfp+0x118>
    2478:	1ac00593          	li	a1,428
    247c:	00090513          	mv	a0,s2
    2480:	ebdfe0ef          	jal	ra,133c <_malloc_r>
    2484:	00050413          	mv	s0,a0
    2488:	08051c63          	bnez	a0,2520 <__sfp+0xf4>
    248c:	0004a023          	sw	zero,0(s1)
    2490:	f91ff0ef          	jal	ra,2420 <__sfp_lock_release>
    2494:	00c00793          	li	a5,12
    2498:	00f92023          	sw	a5,0(s2)
    249c:	0600006f          	j	24fc <__sfp+0xd0>
    24a0:	00c41703          	lh	a4,12(s0)
    24a4:	06071a63          	bnez	a4,2518 <__sfp+0xec>
    24a8:	ffff07b7          	lui	a5,0xffff0
    24ac:	00178793          	addi	a5,a5,1 # ffff0001 <_estack+0xdffd0001>
    24b0:	00f42623          	sw	a5,12(s0)
    24b4:	05840513          	addi	a0,s0,88
    24b8:	06042223          	sw	zero,100(s0)
    24bc:	cc9fe0ef          	jal	ra,1184 <__retarget_lock_init_recursive>
    24c0:	f61ff0ef          	jal	ra,2420 <__sfp_lock_release>
    24c4:	00800613          	li	a2,8
    24c8:	00042023          	sw	zero,0(s0)
    24cc:	00042423          	sw	zero,8(s0)
    24d0:	00042223          	sw	zero,4(s0)
    24d4:	00042823          	sw	zero,16(s0)
    24d8:	00042a23          	sw	zero,20(s0)
    24dc:	00042c23          	sw	zero,24(s0)
    24e0:	00000593          	li	a1,0
    24e4:	05c40513          	addi	a0,s0,92
    24e8:	e84fe0ef          	jal	ra,b6c <memset>
    24ec:	02042a23          	sw	zero,52(s0)
    24f0:	02042c23          	sw	zero,56(s0)
    24f4:	04042423          	sw	zero,72(s0)
    24f8:	04042623          	sw	zero,76(s0)
    24fc:	00c12083          	lw	ra,12(sp)
    2500:	00040513          	mv	a0,s0
    2504:	00812403          	lw	s0,8(sp)
    2508:	00412483          	lw	s1,4(sp)
    250c:	00012903          	lw	s2,0(sp)
    2510:	01010113          	addi	sp,sp,16
    2514:	00008067          	ret
    2518:	06840413          	addi	s0,s0,104
    251c:	f4dff06f          	j	2468 <__sfp+0x3c>
    2520:	00400793          	li	a5,4
    2524:	00052023          	sw	zero,0(a0)
    2528:	00f52223          	sw	a5,4(a0)
    252c:	00c50513          	addi	a0,a0,12
    2530:	00a42423          	sw	a0,8(s0)
    2534:	1a000613          	li	a2,416
    2538:	00000593          	li	a1,0
    253c:	e30fe0ef          	jal	ra,b6c <memset>
    2540:	0084a023          	sw	s0,0(s1)
    2544:	00040493          	mv	s1,s0
    2548:	f19ff06f          	j	2460 <__sfp+0x34>

0000254c <__sinit>:
    254c:	ff010113          	addi	sp,sp,-16
    2550:	00812423          	sw	s0,8(sp)
    2554:	00112623          	sw	ra,12(sp)
    2558:	00050413          	mv	s0,a0
    255c:	eb9ff0ef          	jal	ra,2414 <__sfp_lock_acquire>
    2560:	02042783          	lw	a5,32(s0)
    2564:	00078a63          	beqz	a5,2578 <__sinit+0x2c>
    2568:	00812403          	lw	s0,8(sp)
    256c:	00c12083          	lw	ra,12(sp)
    2570:	01010113          	addi	sp,sp,16
    2574:	eadff06f          	j	2420 <__sfp_lock_release>
    2578:	00000797          	auipc	a5,0x0
    257c:	d5078793          	addi	a5,a5,-688 # 22c8 <cleanup_stdio>
    2580:	02f42023          	sw	a5,32(s0)
    2584:	1fffe797          	auipc	a5,0x1fffe
    2588:	c4c7a783          	lw	a5,-948(a5) # 200001d0 <__stdio_exit_handler>
    258c:	fc079ee3          	bnez	a5,2568 <__sinit+0x1c>
    2590:	e29ff0ef          	jal	ra,23b8 <global_stdio_init.part.0>
    2594:	fd5ff06f          	j	2568 <__sinit+0x1c>

00002598 <__fp_lock_all>:
    2598:	ff010113          	addi	sp,sp,-16
    259c:	00112623          	sw	ra,12(sp)
    25a0:	e75ff0ef          	jal	ra,2414 <__sfp_lock_acquire>
    25a4:	00c12083          	lw	ra,12(sp)
    25a8:	1fffe617          	auipc	a2,0x1fffe
    25ac:	ab060613          	addi	a2,a2,-1360 # 20000058 <__sglue>
    25b0:	00000597          	auipc	a1,0x0
    25b4:	d8858593          	addi	a1,a1,-632 # 2338 <__fp_lock>
    25b8:	00000513          	li	a0,0
    25bc:	01010113          	addi	sp,sp,16
    25c0:	48c0006f          	j	2a4c <_fwalk_sglue>

000025c4 <__fp_unlock_all>:
    25c4:	ff010113          	addi	sp,sp,-16
    25c8:	1fffe617          	auipc	a2,0x1fffe
    25cc:	a9060613          	addi	a2,a2,-1392 # 20000058 <__sglue>
    25d0:	00000597          	auipc	a1,0x0
    25d4:	da858593          	addi	a1,a1,-600 # 2378 <__fp_unlock>
    25d8:	00000513          	li	a0,0
    25dc:	00112623          	sw	ra,12(sp)
    25e0:	46c000ef          	jal	ra,2a4c <_fwalk_sglue>
    25e4:	00c12083          	lw	ra,12(sp)
    25e8:	01010113          	addi	sp,sp,16
    25ec:	e35ff06f          	j	2420 <__sfp_lock_release>

000025f0 <__sfvwrite_r>:
    25f0:	00862783          	lw	a5,8(a2)
    25f4:	00079663          	bnez	a5,2600 <__sfvwrite_r+0x10>
    25f8:	00000513          	li	a0,0
    25fc:	00008067          	ret
    2600:	00c5d783          	lhu	a5,12(a1)
    2604:	fc010113          	addi	sp,sp,-64
    2608:	02812c23          	sw	s0,56(sp)
    260c:	03312623          	sw	s3,44(sp)
    2610:	03512223          	sw	s5,36(sp)
    2614:	02112e23          	sw	ra,60(sp)
    2618:	02912a23          	sw	s1,52(sp)
    261c:	03212823          	sw	s2,48(sp)
    2620:	03412423          	sw	s4,40(sp)
    2624:	03612023          	sw	s6,32(sp)
    2628:	01712e23          	sw	s7,28(sp)
    262c:	01812c23          	sw	s8,24(sp)
    2630:	01912a23          	sw	s9,20(sp)
    2634:	01a12823          	sw	s10,16(sp)
    2638:	01b12623          	sw	s11,12(sp)
    263c:	0087f793          	andi	a5,a5,8
    2640:	00050993          	mv	s3,a0
    2644:	00058413          	mv	s0,a1
    2648:	00060a93          	mv	s5,a2
    264c:	0e078263          	beqz	a5,2730 <__sfvwrite_r+0x140>
    2650:	0105a783          	lw	a5,16(a1)
    2654:	0c078e63          	beqz	a5,2730 <__sfvwrite_r+0x140>
    2658:	00c41783          	lh	a5,12(s0)
    265c:	000aaa03          	lw	s4,0(s5)
    2660:	0027f713          	andi	a4,a5,2
    2664:	16071a63          	bnez	a4,27d8 <__sfvwrite_r+0x1e8>
    2668:	0017f793          	andi	a5,a5,1
    266c:	1e078e63          	beqz	a5,2868 <__sfvwrite_r+0x278>
    2670:	00000b93          	li	s7,0
    2674:	00000513          	li	a0,0
    2678:	00000b13          	li	s6,0
    267c:	00000913          	li	s2,0
    2680:	36090463          	beqz	s2,29e8 <__sfvwrite_r+0x3f8>
    2684:	02051263          	bnez	a0,26a8 <__sfvwrite_r+0xb8>
    2688:	00090613          	mv	a2,s2
    268c:	00a00593          	li	a1,10
    2690:	000b0513          	mv	a0,s6
    2694:	704000ef          	jal	ra,2d98 <memchr>
    2698:	00190b93          	addi	s7,s2,1
    269c:	00050663          	beqz	a0,26a8 <__sfvwrite_r+0xb8>
    26a0:	00150513          	addi	a0,a0,1
    26a4:	41650bb3          	sub	s7,a0,s6
    26a8:	000b8c13          	mv	s8,s7
    26ac:	01797463          	bgeu	s2,s7,26b4 <__sfvwrite_r+0xc4>
    26b0:	00090c13          	mv	s8,s2
    26b4:	00042503          	lw	a0,0(s0)
    26b8:	01042783          	lw	a5,16(s0)
    26bc:	01442683          	lw	a3,20(s0)
    26c0:	32a7fe63          	bgeu	a5,a0,29fc <__sfvwrite_r+0x40c>
    26c4:	00842483          	lw	s1,8(s0)
    26c8:	009684b3          	add	s1,a3,s1
    26cc:	3384d863          	bge	s1,s8,29fc <__sfvwrite_r+0x40c>
    26d0:	000b0593          	mv	a1,s6
    26d4:	00048613          	mv	a2,s1
    26d8:	c58fe0ef          	jal	ra,b30 <memmove>
    26dc:	00042783          	lw	a5,0(s0)
    26e0:	00040593          	mv	a1,s0
    26e4:	00098513          	mv	a0,s3
    26e8:	009787b3          	add	a5,a5,s1
    26ec:	00f42023          	sw	a5,0(s0)
    26f0:	a29ff0ef          	jal	ra,2118 <_fflush_r>
    26f4:	1e051463          	bnez	a0,28dc <__sfvwrite_r+0x2ec>
    26f8:	409b8bb3          	sub	s7,s7,s1
    26fc:	00100513          	li	a0,1
    2700:	000b9a63          	bnez	s7,2714 <__sfvwrite_r+0x124>
    2704:	00040593          	mv	a1,s0
    2708:	00098513          	mv	a0,s3
    270c:	a0dff0ef          	jal	ra,2118 <_fflush_r>
    2710:	1c051663          	bnez	a0,28dc <__sfvwrite_r+0x2ec>
    2714:	008aa783          	lw	a5,8(s5)
    2718:	009b0b33          	add	s6,s6,s1
    271c:	40990933          	sub	s2,s2,s1
    2720:	409787b3          	sub	a5,a5,s1
    2724:	00faa423          	sw	a5,8(s5)
    2728:	f4079ce3          	bnez	a5,2680 <__sfvwrite_r+0x90>
    272c:	06c0006f          	j	2798 <__sfvwrite_r+0x1a8>
    2730:	00040593          	mv	a1,s0
    2734:	00098513          	mv	a0,s3
    2738:	931fe0ef          	jal	ra,1068 <__swsetup_r>
    273c:	f0050ee3          	beqz	a0,2658 <__sfvwrite_r+0x68>
    2740:	fff00513          	li	a0,-1
    2744:	0580006f          	j	279c <__sfvwrite_r+0x1ac>
    2748:	000a2903          	lw	s2,0(s4)
    274c:	004a2483          	lw	s1,4(s4)
    2750:	008a0a13          	addi	s4,s4,8
    2754:	fe048ae3          	beqz	s1,2748 <__sfvwrite_r+0x158>
    2758:	00048693          	mv	a3,s1
    275c:	009b7663          	bgeu	s6,s1,2768 <__sfvwrite_r+0x178>
    2760:	800006b7          	lui	a3,0x80000
    2764:	c0068693          	addi	a3,a3,-1024 # 7ffffc00 <_estack+0x5ffdfc00>
    2768:	02842783          	lw	a5,40(s0)
    276c:	02042583          	lw	a1,32(s0)
    2770:	00090613          	mv	a2,s2
    2774:	00098513          	mv	a0,s3
    2778:	000780e7          	jalr	a5
    277c:	16a05063          	blez	a0,28dc <__sfvwrite_r+0x2ec>
    2780:	008aa783          	lw	a5,8(s5)
    2784:	00a90933          	add	s2,s2,a0
    2788:	40a484b3          	sub	s1,s1,a0
    278c:	40a787b3          	sub	a5,a5,a0
    2790:	00faa423          	sw	a5,8(s5)
    2794:	fc0790e3          	bnez	a5,2754 <__sfvwrite_r+0x164>
    2798:	00000513          	li	a0,0
    279c:	03c12083          	lw	ra,60(sp)
    27a0:	03812403          	lw	s0,56(sp)
    27a4:	03412483          	lw	s1,52(sp)
    27a8:	03012903          	lw	s2,48(sp)
    27ac:	02c12983          	lw	s3,44(sp)
    27b0:	02812a03          	lw	s4,40(sp)
    27b4:	02412a83          	lw	s5,36(sp)
    27b8:	02012b03          	lw	s6,32(sp)
    27bc:	01c12b83          	lw	s7,28(sp)
    27c0:	01812c03          	lw	s8,24(sp)
    27c4:	01412c83          	lw	s9,20(sp)
    27c8:	01012d03          	lw	s10,16(sp)
    27cc:	00c12d83          	lw	s11,12(sp)
    27d0:	04010113          	addi	sp,sp,64
    27d4:	00008067          	ret
    27d8:	80000b37          	lui	s6,0x80000
    27dc:	00000913          	li	s2,0
    27e0:	00000493          	li	s1,0
    27e4:	c00b0b13          	addi	s6,s6,-1024 # 7ffffc00 <_estack+0x5ffdfc00>
    27e8:	f6dff06f          	j	2754 <__sfvwrite_r+0x164>
    27ec:	000a2b03          	lw	s6,0(s4)
    27f0:	004a2483          	lw	s1,4(s4)
    27f4:	008a0a13          	addi	s4,s4,8
    27f8:	fe048ae3          	beqz	s1,27ec <__sfvwrite_r+0x1fc>
    27fc:	00c41783          	lh	a5,12(s0)
    2800:	00042503          	lw	a0,0(s0)
    2804:	00842d03          	lw	s10,8(s0)
    2808:	2007f713          	andi	a4,a5,512
    280c:	14070863          	beqz	a4,295c <__sfvwrite_r+0x36c>
    2810:	000d0d93          	mv	s11,s10
    2814:	07a4f863          	bgeu	s1,s10,2884 <__sfvwrite_r+0x294>
    2818:	00048d13          	mv	s10,s1
    281c:	00048913          	mv	s2,s1
    2820:	00048d93          	mv	s11,s1
    2824:	00042503          	lw	a0,0(s0)
    2828:	000d8613          	mv	a2,s11
    282c:	000b0593          	mv	a1,s6
    2830:	b00fe0ef          	jal	ra,b30 <memmove>
    2834:	00842783          	lw	a5,8(s0)
    2838:	41a787b3          	sub	a5,a5,s10
    283c:	00f42423          	sw	a5,8(s0)
    2840:	00042783          	lw	a5,0(s0)
    2844:	01b787b3          	add	a5,a5,s11
    2848:	00f42023          	sw	a5,0(s0)
    284c:	008aa783          	lw	a5,8(s5)
    2850:	012b0b33          	add	s6,s6,s2
    2854:	412484b3          	sub	s1,s1,s2
    2858:	412787b3          	sub	a5,a5,s2
    285c:	00faa423          	sw	a5,8(s5)
    2860:	f8079ce3          	bnez	a5,27f8 <__sfvwrite_r+0x208>
    2864:	f35ff06f          	j	2798 <__sfvwrite_r+0x1a8>
    2868:	80000bb7          	lui	s7,0x80000
    286c:	00000b13          	li	s6,0
    2870:	00000493          	li	s1,0
    2874:	fffb8b93          	addi	s7,s7,-1 # 7fffffff <_estack+0x5ffdffff>
    2878:	00300c13          	li	s8,3
    287c:	00200c93          	li	s9,2
    2880:	f79ff06f          	j	27f8 <__sfvwrite_r+0x208>
    2884:	4807f713          	andi	a4,a5,1152
    2888:	0c070663          	beqz	a4,2954 <__sfvwrite_r+0x364>
    288c:	01442903          	lw	s2,20(s0)
    2890:	01042583          	lw	a1,16(s0)
    2894:	03890933          	mul	s2,s2,s8
    2898:	40b50db3          	sub	s11,a0,a1
    289c:	001d8713          	addi	a4,s11,1
    28a0:	00970733          	add	a4,a4,s1
    28a4:	03994933          	div	s2,s2,s9
    28a8:	00090613          	mv	a2,s2
    28ac:	00e97663          	bgeu	s2,a4,28b8 <__sfvwrite_r+0x2c8>
    28b0:	00070913          	mv	s2,a4
    28b4:	00070613          	mv	a2,a4
    28b8:	4007f793          	andi	a5,a5,1024
    28bc:	06078663          	beqz	a5,2928 <__sfvwrite_r+0x338>
    28c0:	00060593          	mv	a1,a2
    28c4:	00098513          	mv	a0,s3
    28c8:	a75fe0ef          	jal	ra,133c <_malloc_r>
    28cc:	00050d13          	mv	s10,a0
    28d0:	00051e63          	bnez	a0,28ec <__sfvwrite_r+0x2fc>
    28d4:	00c00793          	li	a5,12
    28d8:	00f9a023          	sw	a5,0(s3)
    28dc:	00c45783          	lhu	a5,12(s0)
    28e0:	0407e793          	ori	a5,a5,64
    28e4:	00f41623          	sh	a5,12(s0)
    28e8:	e59ff06f          	j	2740 <__sfvwrite_r+0x150>
    28ec:	01042583          	lw	a1,16(s0)
    28f0:	000d8613          	mv	a2,s11
    28f4:	a94fe0ef          	jal	ra,b88 <memcpy>
    28f8:	00c45783          	lhu	a5,12(s0)
    28fc:	b7f7f793          	andi	a5,a5,-1153
    2900:	0807e793          	ori	a5,a5,128
    2904:	00f41623          	sh	a5,12(s0)
    2908:	01a42823          	sw	s10,16(s0)
    290c:	01242a23          	sw	s2,20(s0)
    2910:	01bd0d33          	add	s10,s10,s11
    2914:	41b90933          	sub	s2,s2,s11
    2918:	01a42023          	sw	s10,0(s0)
    291c:	01242423          	sw	s2,8(s0)
    2920:	00048d13          	mv	s10,s1
    2924:	ef9ff06f          	j	281c <__sfvwrite_r+0x22c>
    2928:	00098513          	mv	a0,s3
    292c:	021000ef          	jal	ra,314c <_realloc_r>
    2930:	00050d13          	mv	s10,a0
    2934:	fc051ae3          	bnez	a0,2908 <__sfvwrite_r+0x318>
    2938:	01042583          	lw	a1,16(s0)
    293c:	00098513          	mv	a0,s3
    2940:	871fe0ef          	jal	ra,11b0 <_free_r>
    2944:	00c45783          	lhu	a5,12(s0)
    2948:	f7f7f793          	andi	a5,a5,-129
    294c:	00f41623          	sh	a5,12(s0)
    2950:	f85ff06f          	j	28d4 <__sfvwrite_r+0x2e4>
    2954:	00048913          	mv	s2,s1
    2958:	ecdff06f          	j	2824 <__sfvwrite_r+0x234>
    295c:	01042783          	lw	a5,16(s0)
    2960:	00a7e663          	bltu	a5,a0,296c <__sfvwrite_r+0x37c>
    2964:	01442683          	lw	a3,20(s0)
    2968:	04d4f663          	bgeu	s1,a3,29b4 <__sfvwrite_r+0x3c4>
    296c:	000d0913          	mv	s2,s10
    2970:	01a4f463          	bgeu	s1,s10,2978 <__sfvwrite_r+0x388>
    2974:	00048913          	mv	s2,s1
    2978:	00090613          	mv	a2,s2
    297c:	000b0593          	mv	a1,s6
    2980:	9b0fe0ef          	jal	ra,b30 <memmove>
    2984:	00842783          	lw	a5,8(s0)
    2988:	00042703          	lw	a4,0(s0)
    298c:	412787b3          	sub	a5,a5,s2
    2990:	01270733          	add	a4,a4,s2
    2994:	00f42423          	sw	a5,8(s0)
    2998:	00e42023          	sw	a4,0(s0)
    299c:	ea0798e3          	bnez	a5,284c <__sfvwrite_r+0x25c>
    29a0:	00040593          	mv	a1,s0
    29a4:	00098513          	mv	a0,s3
    29a8:	f70ff0ef          	jal	ra,2118 <_fflush_r>
    29ac:	ea0500e3          	beqz	a0,284c <__sfvwrite_r+0x25c>
    29b0:	f2dff06f          	j	28dc <__sfvwrite_r+0x2ec>
    29b4:	00048793          	mv	a5,s1
    29b8:	009bf463          	bgeu	s7,s1,29c0 <__sfvwrite_r+0x3d0>
    29bc:	000b8793          	mv	a5,s7
    29c0:	02d7c7b3          	div	a5,a5,a3
    29c4:	02842703          	lw	a4,40(s0)
    29c8:	02042583          	lw	a1,32(s0)
    29cc:	000b0613          	mv	a2,s6
    29d0:	00098513          	mv	a0,s3
    29d4:	02d786b3          	mul	a3,a5,a3
    29d8:	000700e7          	jalr	a4
    29dc:	00050913          	mv	s2,a0
    29e0:	e6a046e3          	bgtz	a0,284c <__sfvwrite_r+0x25c>
    29e4:	ef9ff06f          	j	28dc <__sfvwrite_r+0x2ec>
    29e8:	000a2b03          	lw	s6,0(s4)
    29ec:	004a2903          	lw	s2,4(s4)
    29f0:	00000513          	li	a0,0
    29f4:	008a0a13          	addi	s4,s4,8
    29f8:	c89ff06f          	j	2680 <__sfvwrite_r+0x90>
    29fc:	02dc4263          	blt	s8,a3,2a20 <__sfvwrite_r+0x430>
    2a00:	02842783          	lw	a5,40(s0)
    2a04:	02042583          	lw	a1,32(s0)
    2a08:	000b0613          	mv	a2,s6
    2a0c:	00098513          	mv	a0,s3
    2a10:	000780e7          	jalr	a5
    2a14:	00050493          	mv	s1,a0
    2a18:	cea040e3          	bgtz	a0,26f8 <__sfvwrite_r+0x108>
    2a1c:	ec1ff06f          	j	28dc <__sfvwrite_r+0x2ec>
    2a20:	000c0613          	mv	a2,s8
    2a24:	000b0593          	mv	a1,s6
    2a28:	908fe0ef          	jal	ra,b30 <memmove>
    2a2c:	00842783          	lw	a5,8(s0)
    2a30:	000c0493          	mv	s1,s8
    2a34:	418787b3          	sub	a5,a5,s8
    2a38:	00f42423          	sw	a5,8(s0)
    2a3c:	00042783          	lw	a5,0(s0)
    2a40:	018787b3          	add	a5,a5,s8
    2a44:	00f42023          	sw	a5,0(s0)
    2a48:	cb1ff06f          	j	26f8 <__sfvwrite_r+0x108>

00002a4c <_fwalk_sglue>:
    2a4c:	fd010113          	addi	sp,sp,-48
    2a50:	02812423          	sw	s0,40(sp)
    2a54:	03212023          	sw	s2,32(sp)
    2a58:	01312e23          	sw	s3,28(sp)
    2a5c:	01412c23          	sw	s4,24(sp)
    2a60:	01612823          	sw	s6,16(sp)
    2a64:	01712623          	sw	s7,12(sp)
    2a68:	02112623          	sw	ra,44(sp)
    2a6c:	02912223          	sw	s1,36(sp)
    2a70:	01512a23          	sw	s5,20(sp)
    2a74:	00050993          	mv	s3,a0
    2a78:	00058a13          	mv	s4,a1
    2a7c:	00060413          	mv	s0,a2
    2a80:	00000913          	li	s2,0
    2a84:	00100b13          	li	s6,1
    2a88:	fff00b93          	li	s7,-1
    2a8c:	00842483          	lw	s1,8(s0)
    2a90:	00442a83          	lw	s5,4(s0)
    2a94:	fffa8a93          	addi	s5,s5,-1
    2a98:	020ade63          	bgez	s5,2ad4 <_fwalk_sglue+0x88>
    2a9c:	00042403          	lw	s0,0(s0)
    2aa0:	fe0416e3          	bnez	s0,2a8c <_fwalk_sglue+0x40>
    2aa4:	02c12083          	lw	ra,44(sp)
    2aa8:	02812403          	lw	s0,40(sp)
    2aac:	02412483          	lw	s1,36(sp)
    2ab0:	01c12983          	lw	s3,28(sp)
    2ab4:	01812a03          	lw	s4,24(sp)
    2ab8:	01412a83          	lw	s5,20(sp)
    2abc:	01012b03          	lw	s6,16(sp)
    2ac0:	00c12b83          	lw	s7,12(sp)
    2ac4:	00090513          	mv	a0,s2
    2ac8:	02012903          	lw	s2,32(sp)
    2acc:	03010113          	addi	sp,sp,48
    2ad0:	00008067          	ret
    2ad4:	00c4d783          	lhu	a5,12(s1)
    2ad8:	00fb7e63          	bgeu	s6,a5,2af4 <_fwalk_sglue+0xa8>
    2adc:	00e49783          	lh	a5,14(s1)
    2ae0:	01778a63          	beq	a5,s7,2af4 <_fwalk_sglue+0xa8>
    2ae4:	00048593          	mv	a1,s1
    2ae8:	00098513          	mv	a0,s3
    2aec:	000a00e7          	jalr	s4
    2af0:	00a96933          	or	s2,s2,a0
    2af4:	06848493          	addi	s1,s1,104
    2af8:	f9dff06f          	j	2a94 <_fwalk_sglue+0x48>

00002afc <__swhatbuf_r>:
    2afc:	f9010113          	addi	sp,sp,-112
    2b00:	06812423          	sw	s0,104(sp)
    2b04:	00058413          	mv	s0,a1
    2b08:	00e59583          	lh	a1,14(a1)
    2b0c:	06912223          	sw	s1,100(sp)
    2b10:	07212023          	sw	s2,96(sp)
    2b14:	06112623          	sw	ra,108(sp)
    2b18:	00060493          	mv	s1,a2
    2b1c:	00068913          	mv	s2,a3
    2b20:	0205dc63          	bgez	a1,2b58 <__swhatbuf_r+0x5c>
    2b24:	00c45783          	lhu	a5,12(s0)
    2b28:	0807f793          	andi	a5,a5,128
    2b2c:	04079a63          	bnez	a5,2b80 <__swhatbuf_r+0x84>
    2b30:	40000713          	li	a4,1024
    2b34:	06c12083          	lw	ra,108(sp)
    2b38:	06812403          	lw	s0,104(sp)
    2b3c:	00f92023          	sw	a5,0(s2)
    2b40:	00e4a023          	sw	a4,0(s1)
    2b44:	06012903          	lw	s2,96(sp)
    2b48:	06412483          	lw	s1,100(sp)
    2b4c:	00000513          	li	a0,0
    2b50:	07010113          	addi	sp,sp,112
    2b54:	00008067          	ret
    2b58:	00810613          	addi	a2,sp,8
    2b5c:	424000ef          	jal	ra,2f80 <_fstat_r>
    2b60:	fc0542e3          	bltz	a0,2b24 <__swhatbuf_r+0x28>
    2b64:	00c12783          	lw	a5,12(sp)
    2b68:	0000f737          	lui	a4,0xf
    2b6c:	00e7f7b3          	and	a5,a5,a4
    2b70:	ffffe737          	lui	a4,0xffffe
    2b74:	00e787b3          	add	a5,a5,a4
    2b78:	0017b793          	seqz	a5,a5
    2b7c:	fb5ff06f          	j	2b30 <__swhatbuf_r+0x34>
    2b80:	00000793          	li	a5,0
    2b84:	04000713          	li	a4,64
    2b88:	fadff06f          	j	2b34 <__swhatbuf_r+0x38>

00002b8c <__smakebuf_r>:
    2b8c:	00c5d783          	lhu	a5,12(a1)
    2b90:	fe010113          	addi	sp,sp,-32
    2b94:	00812c23          	sw	s0,24(sp)
    2b98:	00112e23          	sw	ra,28(sp)
    2b9c:	00912a23          	sw	s1,20(sp)
    2ba0:	01212823          	sw	s2,16(sp)
    2ba4:	0027f793          	andi	a5,a5,2
    2ba8:	00058413          	mv	s0,a1
    2bac:	02078863          	beqz	a5,2bdc <__smakebuf_r+0x50>
    2bb0:	04740793          	addi	a5,s0,71
    2bb4:	00f42023          	sw	a5,0(s0)
    2bb8:	00f42823          	sw	a5,16(s0)
    2bbc:	00100793          	li	a5,1
    2bc0:	00f42a23          	sw	a5,20(s0)
    2bc4:	01c12083          	lw	ra,28(sp)
    2bc8:	01812403          	lw	s0,24(sp)
    2bcc:	01412483          	lw	s1,20(sp)
    2bd0:	01012903          	lw	s2,16(sp)
    2bd4:	02010113          	addi	sp,sp,32
    2bd8:	00008067          	ret
    2bdc:	00c10693          	addi	a3,sp,12
    2be0:	00810613          	addi	a2,sp,8
    2be4:	00050493          	mv	s1,a0
    2be8:	f15ff0ef          	jal	ra,2afc <__swhatbuf_r>
    2bec:	00812903          	lw	s2,8(sp)
    2bf0:	00048513          	mv	a0,s1
    2bf4:	00090593          	mv	a1,s2
    2bf8:	f44fe0ef          	jal	ra,133c <_malloc_r>
    2bfc:	00c41783          	lh	a5,12(s0)
    2c00:	00051e63          	bnez	a0,2c1c <__smakebuf_r+0x90>
    2c04:	2007f713          	andi	a4,a5,512
    2c08:	fa071ee3          	bnez	a4,2bc4 <__smakebuf_r+0x38>
    2c0c:	ffc7f793          	andi	a5,a5,-4
    2c10:	0027e793          	ori	a5,a5,2
    2c14:	00f41623          	sh	a5,12(s0)
    2c18:	f99ff06f          	j	2bb0 <__smakebuf_r+0x24>
    2c1c:	0807e793          	ori	a5,a5,128
    2c20:	00f41623          	sh	a5,12(s0)
    2c24:	00c12783          	lw	a5,12(sp)
    2c28:	00a42023          	sw	a0,0(s0)
    2c2c:	00a42823          	sw	a0,16(s0)
    2c30:	01242a23          	sw	s2,20(s0)
    2c34:	f80788e3          	beqz	a5,2bc4 <__smakebuf_r+0x38>
    2c38:	00e41583          	lh	a1,14(s0)
    2c3c:	00048513          	mv	a0,s1
    2c40:	38c000ef          	jal	ra,2fcc <_isatty_r>
    2c44:	f80500e3          	beqz	a0,2bc4 <__smakebuf_r+0x38>
    2c48:	00c45783          	lhu	a5,12(s0)
    2c4c:	ffc7f793          	andi	a5,a5,-4
    2c50:	0017e793          	ori	a5,a5,1
    2c54:	00f41623          	sh	a5,12(s0)
    2c58:	f6dff06f          	j	2bc4 <__smakebuf_r+0x38>

00002c5c <__sread>:
    2c5c:	ff010113          	addi	sp,sp,-16
    2c60:	00812423          	sw	s0,8(sp)
    2c64:	00058413          	mv	s0,a1
    2c68:	00e59583          	lh	a1,14(a1)
    2c6c:	00112623          	sw	ra,12(sp)
    2c70:	3f4000ef          	jal	ra,3064 <_read_r>
    2c74:	02054063          	bltz	a0,2c94 <__sread+0x38>
    2c78:	05442783          	lw	a5,84(s0)
    2c7c:	00a787b3          	add	a5,a5,a0
    2c80:	04f42a23          	sw	a5,84(s0)
    2c84:	00c12083          	lw	ra,12(sp)
    2c88:	00812403          	lw	s0,8(sp)
    2c8c:	01010113          	addi	sp,sp,16
    2c90:	00008067          	ret
    2c94:	00c45783          	lhu	a5,12(s0)
    2c98:	fffff737          	lui	a4,0xfffff
    2c9c:	fff70713          	addi	a4,a4,-1 # ffffefff <_estack+0xdffdefff>
    2ca0:	00e7f7b3          	and	a5,a5,a4
    2ca4:	00f41623          	sh	a5,12(s0)
    2ca8:	fddff06f          	j	2c84 <__sread+0x28>

00002cac <__seofread>:
    2cac:	00000513          	li	a0,0
    2cb0:	00008067          	ret

00002cb4 <__swrite>:
    2cb4:	00c5d783          	lhu	a5,12(a1)
    2cb8:	fe010113          	addi	sp,sp,-32
    2cbc:	00812c23          	sw	s0,24(sp)
    2cc0:	00912a23          	sw	s1,20(sp)
    2cc4:	01212823          	sw	s2,16(sp)
    2cc8:	01312623          	sw	s3,12(sp)
    2ccc:	00112e23          	sw	ra,28(sp)
    2cd0:	1007f793          	andi	a5,a5,256
    2cd4:	00050493          	mv	s1,a0
    2cd8:	00058413          	mv	s0,a1
    2cdc:	00060913          	mv	s2,a2
    2ce0:	00068993          	mv	s3,a3
    2ce4:	00078a63          	beqz	a5,2cf8 <__swrite+0x44>
    2ce8:	00e59583          	lh	a1,14(a1)
    2cec:	00200693          	li	a3,2
    2cf0:	00000613          	li	a2,0
    2cf4:	320000ef          	jal	ra,3014 <_lseek_r>
    2cf8:	00c45783          	lhu	a5,12(s0)
    2cfc:	fffff737          	lui	a4,0xfffff
    2d00:	fff70713          	addi	a4,a4,-1 # ffffefff <_estack+0xdffdefff>
    2d04:	00e7f7b3          	and	a5,a5,a4
    2d08:	00e41583          	lh	a1,14(s0)
    2d0c:	00f41623          	sh	a5,12(s0)
    2d10:	01812403          	lw	s0,24(sp)
    2d14:	01c12083          	lw	ra,28(sp)
    2d18:	00098693          	mv	a3,s3
    2d1c:	00090613          	mv	a2,s2
    2d20:	00c12983          	lw	s3,12(sp)
    2d24:	01012903          	lw	s2,16(sp)
    2d28:	00048513          	mv	a0,s1
    2d2c:	01412483          	lw	s1,20(sp)
    2d30:	02010113          	addi	sp,sp,32
    2d34:	3c80006f          	j	30fc <_write_r>

00002d38 <__sseek>:
    2d38:	ff010113          	addi	sp,sp,-16
    2d3c:	00812423          	sw	s0,8(sp)
    2d40:	00058413          	mv	s0,a1
    2d44:	00e59583          	lh	a1,14(a1)
    2d48:	00112623          	sw	ra,12(sp)
    2d4c:	2c8000ef          	jal	ra,3014 <_lseek_r>
    2d50:	fff00713          	li	a4,-1
    2d54:	00c41783          	lh	a5,12(s0)
    2d58:	02e51263          	bne	a0,a4,2d7c <__sseek+0x44>
    2d5c:	fffff737          	lui	a4,0xfffff
    2d60:	fff70713          	addi	a4,a4,-1 # ffffefff <_estack+0xdffdefff>
    2d64:	00e7f7b3          	and	a5,a5,a4
    2d68:	00f41623          	sh	a5,12(s0)
    2d6c:	00c12083          	lw	ra,12(sp)
    2d70:	00812403          	lw	s0,8(sp)
    2d74:	01010113          	addi	sp,sp,16
    2d78:	00008067          	ret
    2d7c:	00001737          	lui	a4,0x1
    2d80:	00e7e7b3          	or	a5,a5,a4
    2d84:	00f41623          	sh	a5,12(s0)
    2d88:	04a42a23          	sw	a0,84(s0)
    2d8c:	fe1ff06f          	j	2d6c <__sseek+0x34>

00002d90 <__sclose>:
    2d90:	00e59583          	lh	a1,14(a1)
    2d94:	0280006f          	j	2dbc <_close_r>

00002d98 <memchr>:
    2d98:	0ff5f593          	andi	a1,a1,255
    2d9c:	00c50633          	add	a2,a0,a2
    2da0:	00c51663          	bne	a0,a2,2dac <memchr+0x14>
    2da4:	00000513          	li	a0,0
    2da8:	00008067          	ret
    2dac:	00054783          	lbu	a5,0(a0)
    2db0:	feb78ce3          	beq	a5,a1,2da8 <memchr+0x10>
    2db4:	00150513          	addi	a0,a0,1
    2db8:	fe9ff06f          	j	2da0 <memchr+0x8>

00002dbc <_close_r>:
    2dbc:	ff010113          	addi	sp,sp,-16
    2dc0:	00812423          	sw	s0,8(sp)
    2dc4:	00050413          	mv	s0,a0
    2dc8:	00058513          	mv	a0,a1
    2dcc:	1fffd797          	auipc	a5,0x1fffd
    2dd0:	4007a423          	sw	zero,1032(a5) # 200001d4 <errno>
    2dd4:	00112623          	sw	ra,12(sp)
    2dd8:	85dfd0ef          	jal	ra,634 <_close>
    2ddc:	fff00793          	li	a5,-1
    2de0:	00f51a63          	bne	a0,a5,2df4 <_close_r+0x38>
    2de4:	1fffd797          	auipc	a5,0x1fffd
    2de8:	3f07a783          	lw	a5,1008(a5) # 200001d4 <errno>
    2dec:	00078463          	beqz	a5,2df4 <_close_r+0x38>
    2df0:	00f42023          	sw	a5,0(s0)
    2df4:	00c12083          	lw	ra,12(sp)
    2df8:	00812403          	lw	s0,8(sp)
    2dfc:	01010113          	addi	sp,sp,16
    2e00:	00008067          	ret

00002e04 <_reclaim_reent>:
    2e04:	1fffd797          	auipc	a5,0x1fffd
    2e08:	2047a783          	lw	a5,516(a5) # 20000008 <_impure_ptr>
    2e0c:	16a78863          	beq	a5,a0,2f7c <_reclaim_reent+0x178>
    2e10:	01c52783          	lw	a5,28(a0)
    2e14:	fe010113          	addi	sp,sp,-32
    2e18:	00812c23          	sw	s0,24(sp)
    2e1c:	00112e23          	sw	ra,28(sp)
    2e20:	00912a23          	sw	s1,20(sp)
    2e24:	01212823          	sw	s2,16(sp)
    2e28:	01312623          	sw	s3,12(sp)
    2e2c:	00050413          	mv	s0,a0
    2e30:	08078463          	beqz	a5,2eb8 <_reclaim_reent+0xb4>
    2e34:	00c7a783          	lw	a5,12(a5)
    2e38:	02078c63          	beqz	a5,2e70 <_reclaim_reent+0x6c>
    2e3c:	00000493          	li	s1,0
    2e40:	08000913          	li	s2,128
    2e44:	01c42783          	lw	a5,28(s0)
    2e48:	00c7a783          	lw	a5,12(a5)
    2e4c:	009787b3          	add	a5,a5,s1
    2e50:	0007a583          	lw	a1,0(a5)
    2e54:	04059863          	bnez	a1,2ea4 <_reclaim_reent+0xa0>
    2e58:	00448493          	addi	s1,s1,4
    2e5c:	ff2494e3          	bne	s1,s2,2e44 <_reclaim_reent+0x40>
    2e60:	01c42783          	lw	a5,28(s0)
    2e64:	00040513          	mv	a0,s0
    2e68:	00c7a583          	lw	a1,12(a5)
    2e6c:	b44fe0ef          	jal	ra,11b0 <_free_r>
    2e70:	01c42783          	lw	a5,28(s0)
    2e74:	0007a583          	lw	a1,0(a5)
    2e78:	00058663          	beqz	a1,2e84 <_reclaim_reent+0x80>
    2e7c:	00040513          	mv	a0,s0
    2e80:	b30fe0ef          	jal	ra,11b0 <_free_r>
    2e84:	01c42783          	lw	a5,28(s0)
    2e88:	0087a483          	lw	s1,8(a5)
    2e8c:	02048663          	beqz	s1,2eb8 <_reclaim_reent+0xb4>
    2e90:	00048593          	mv	a1,s1
    2e94:	00040513          	mv	a0,s0
    2e98:	0004a483          	lw	s1,0(s1)
    2e9c:	b14fe0ef          	jal	ra,11b0 <_free_r>
    2ea0:	fedff06f          	j	2e8c <_reclaim_reent+0x88>
    2ea4:	0005a983          	lw	s3,0(a1)
    2ea8:	00040513          	mv	a0,s0
    2eac:	b04fe0ef          	jal	ra,11b0 <_free_r>
    2eb0:	00098593          	mv	a1,s3
    2eb4:	fa1ff06f          	j	2e54 <_reclaim_reent+0x50>
    2eb8:	01442583          	lw	a1,20(s0)
    2ebc:	00058663          	beqz	a1,2ec8 <_reclaim_reent+0xc4>
    2ec0:	00040513          	mv	a0,s0
    2ec4:	aecfe0ef          	jal	ra,11b0 <_free_r>
    2ec8:	01c42583          	lw	a1,28(s0)
    2ecc:	00058663          	beqz	a1,2ed8 <_reclaim_reent+0xd4>
    2ed0:	00040513          	mv	a0,s0
    2ed4:	adcfe0ef          	jal	ra,11b0 <_free_r>
    2ed8:	03042583          	lw	a1,48(s0)
    2edc:	00058663          	beqz	a1,2ee8 <_reclaim_reent+0xe4>
    2ee0:	00040513          	mv	a0,s0
    2ee4:	accfe0ef          	jal	ra,11b0 <_free_r>
    2ee8:	03442583          	lw	a1,52(s0)
    2eec:	00058663          	beqz	a1,2ef8 <_reclaim_reent+0xf4>
    2ef0:	00040513          	mv	a0,s0
    2ef4:	abcfe0ef          	jal	ra,11b0 <_free_r>
    2ef8:	03842583          	lw	a1,56(s0)
    2efc:	00058663          	beqz	a1,2f08 <_reclaim_reent+0x104>
    2f00:	00040513          	mv	a0,s0
    2f04:	aacfe0ef          	jal	ra,11b0 <_free_r>
    2f08:	04842583          	lw	a1,72(s0)
    2f0c:	00058663          	beqz	a1,2f18 <_reclaim_reent+0x114>
    2f10:	00040513          	mv	a0,s0
    2f14:	a9cfe0ef          	jal	ra,11b0 <_free_r>
    2f18:	04442583          	lw	a1,68(s0)
    2f1c:	00058663          	beqz	a1,2f28 <_reclaim_reent+0x124>
    2f20:	00040513          	mv	a0,s0
    2f24:	a8cfe0ef          	jal	ra,11b0 <_free_r>
    2f28:	02c42583          	lw	a1,44(s0)
    2f2c:	00058663          	beqz	a1,2f38 <_reclaim_reent+0x134>
    2f30:	00040513          	mv	a0,s0
    2f34:	a7cfe0ef          	jal	ra,11b0 <_free_r>
    2f38:	02042783          	lw	a5,32(s0)
    2f3c:	02078263          	beqz	a5,2f60 <_reclaim_reent+0x15c>
    2f40:	00040513          	mv	a0,s0
    2f44:	01812403          	lw	s0,24(sp)
    2f48:	01c12083          	lw	ra,28(sp)
    2f4c:	01412483          	lw	s1,20(sp)
    2f50:	01012903          	lw	s2,16(sp)
    2f54:	00c12983          	lw	s3,12(sp)
    2f58:	02010113          	addi	sp,sp,32
    2f5c:	00078067          	jr	a5
    2f60:	01c12083          	lw	ra,28(sp)
    2f64:	01812403          	lw	s0,24(sp)
    2f68:	01412483          	lw	s1,20(sp)
    2f6c:	01012903          	lw	s2,16(sp)
    2f70:	00c12983          	lw	s3,12(sp)
    2f74:	02010113          	addi	sp,sp,32
    2f78:	00008067          	ret
    2f7c:	00008067          	ret

00002f80 <_fstat_r>:
    2f80:	ff010113          	addi	sp,sp,-16
    2f84:	00812423          	sw	s0,8(sp)
    2f88:	00050413          	mv	s0,a0
    2f8c:	00058513          	mv	a0,a1
    2f90:	00060593          	mv	a1,a2
    2f94:	1fffd797          	auipc	a5,0x1fffd
    2f98:	2407a023          	sw	zero,576(a5) # 200001d4 <errno>
    2f9c:	00112623          	sw	ra,12(sp)
    2fa0:	e9cfd0ef          	jal	ra,63c <_fstat>
    2fa4:	fff00793          	li	a5,-1
    2fa8:	00f51a63          	bne	a0,a5,2fbc <_fstat_r+0x3c>
    2fac:	1fffd797          	auipc	a5,0x1fffd
    2fb0:	2287a783          	lw	a5,552(a5) # 200001d4 <errno>
    2fb4:	00078463          	beqz	a5,2fbc <_fstat_r+0x3c>
    2fb8:	00f42023          	sw	a5,0(s0)
    2fbc:	00c12083          	lw	ra,12(sp)
    2fc0:	00812403          	lw	s0,8(sp)
    2fc4:	01010113          	addi	sp,sp,16
    2fc8:	00008067          	ret

00002fcc <_isatty_r>:
    2fcc:	ff010113          	addi	sp,sp,-16
    2fd0:	00812423          	sw	s0,8(sp)
    2fd4:	00050413          	mv	s0,a0
    2fd8:	00058513          	mv	a0,a1
    2fdc:	1fffd797          	auipc	a5,0x1fffd
    2fe0:	1e07ac23          	sw	zero,504(a5) # 200001d4 <errno>
    2fe4:	00112623          	sw	ra,12(sp)
    2fe8:	e5cfd0ef          	jal	ra,644 <_isatty>
    2fec:	fff00793          	li	a5,-1
    2ff0:	00f51a63          	bne	a0,a5,3004 <_isatty_r+0x38>
    2ff4:	1fffd797          	auipc	a5,0x1fffd
    2ff8:	1e07a783          	lw	a5,480(a5) # 200001d4 <errno>
    2ffc:	00078463          	beqz	a5,3004 <_isatty_r+0x38>
    3000:	00f42023          	sw	a5,0(s0)
    3004:	00c12083          	lw	ra,12(sp)
    3008:	00812403          	lw	s0,8(sp)
    300c:	01010113          	addi	sp,sp,16
    3010:	00008067          	ret

00003014 <_lseek_r>:
    3014:	ff010113          	addi	sp,sp,-16
    3018:	00812423          	sw	s0,8(sp)
    301c:	00050413          	mv	s0,a0
    3020:	00058513          	mv	a0,a1
    3024:	00060593          	mv	a1,a2
    3028:	00068613          	mv	a2,a3
    302c:	1fffd797          	auipc	a5,0x1fffd
    3030:	1a07a423          	sw	zero,424(a5) # 200001d4 <errno>
    3034:	00112623          	sw	ra,12(sp)
    3038:	e14fd0ef          	jal	ra,64c <_lseek>
    303c:	fff00793          	li	a5,-1
    3040:	00f51a63          	bne	a0,a5,3054 <_lseek_r+0x40>
    3044:	1fffd797          	auipc	a5,0x1fffd
    3048:	1907a783          	lw	a5,400(a5) # 200001d4 <errno>
    304c:	00078463          	beqz	a5,3054 <_lseek_r+0x40>
    3050:	00f42023          	sw	a5,0(s0)
    3054:	00c12083          	lw	ra,12(sp)
    3058:	00812403          	lw	s0,8(sp)
    305c:	01010113          	addi	sp,sp,16
    3060:	00008067          	ret

00003064 <_read_r>:
    3064:	ff010113          	addi	sp,sp,-16
    3068:	00812423          	sw	s0,8(sp)
    306c:	00050413          	mv	s0,a0
    3070:	00058513          	mv	a0,a1
    3074:	00060593          	mv	a1,a2
    3078:	00068613          	mv	a2,a3
    307c:	1fffd797          	auipc	a5,0x1fffd
    3080:	1407ac23          	sw	zero,344(a5) # 200001d4 <errno>
    3084:	00112623          	sw	ra,12(sp)
    3088:	dccfd0ef          	jal	ra,654 <_read>
    308c:	fff00793          	li	a5,-1
    3090:	00f51a63          	bne	a0,a5,30a4 <_read_r+0x40>
    3094:	1fffd797          	auipc	a5,0x1fffd
    3098:	1407a783          	lw	a5,320(a5) # 200001d4 <errno>
    309c:	00078463          	beqz	a5,30a4 <_read_r+0x40>
    30a0:	00f42023          	sw	a5,0(s0)
    30a4:	00c12083          	lw	ra,12(sp)
    30a8:	00812403          	lw	s0,8(sp)
    30ac:	01010113          	addi	sp,sp,16
    30b0:	00008067          	ret

000030b4 <_sbrk_r>:
    30b4:	ff010113          	addi	sp,sp,-16
    30b8:	00812423          	sw	s0,8(sp)
    30bc:	00050413          	mv	s0,a0
    30c0:	00058513          	mv	a0,a1
    30c4:	1fffd797          	auipc	a5,0x1fffd
    30c8:	1007a823          	sw	zero,272(a5) # 200001d4 <errno>
    30cc:	00112623          	sw	ra,12(sp)
    30d0:	d30fd0ef          	jal	ra,600 <_sbrk>
    30d4:	fff00793          	li	a5,-1
    30d8:	00f51a63          	bne	a0,a5,30ec <_sbrk_r+0x38>
    30dc:	1fffd797          	auipc	a5,0x1fffd
    30e0:	0f87a783          	lw	a5,248(a5) # 200001d4 <errno>
    30e4:	00078463          	beqz	a5,30ec <_sbrk_r+0x38>
    30e8:	00f42023          	sw	a5,0(s0)
    30ec:	00c12083          	lw	ra,12(sp)
    30f0:	00812403          	lw	s0,8(sp)
    30f4:	01010113          	addi	sp,sp,16
    30f8:	00008067          	ret

000030fc <_write_r>:
    30fc:	ff010113          	addi	sp,sp,-16
    3100:	00812423          	sw	s0,8(sp)
    3104:	00050413          	mv	s0,a0
    3108:	00058513          	mv	a0,a1
    310c:	00060593          	mv	a1,a2
    3110:	00068613          	mv	a2,a3
    3114:	1fffd797          	auipc	a5,0x1fffd
    3118:	0c07a023          	sw	zero,192(a5) # 200001d4 <errno>
    311c:	00112623          	sw	ra,12(sp)
    3120:	120000ef          	jal	ra,3240 <_write>
    3124:	fff00793          	li	a5,-1
    3128:	00f51a63          	bne	a0,a5,313c <_write_r+0x40>
    312c:	1fffd797          	auipc	a5,0x1fffd
    3130:	0a87a783          	lw	a5,168(a5) # 200001d4 <errno>
    3134:	00078463          	beqz	a5,313c <_write_r+0x40>
    3138:	00f42023          	sw	a5,0(s0)
    313c:	00c12083          	lw	ra,12(sp)
    3140:	00812403          	lw	s0,8(sp)
    3144:	01010113          	addi	sp,sp,16
    3148:	00008067          	ret

0000314c <_realloc_r>:
    314c:	fe010113          	addi	sp,sp,-32
    3150:	00812c23          	sw	s0,24(sp)
    3154:	00112e23          	sw	ra,28(sp)
    3158:	00912a23          	sw	s1,20(sp)
    315c:	01212823          	sw	s2,16(sp)
    3160:	01312623          	sw	s3,12(sp)
    3164:	01412423          	sw	s4,8(sp)
    3168:	00060413          	mv	s0,a2
    316c:	02059463          	bnez	a1,3194 <_realloc_r+0x48>
    3170:	01812403          	lw	s0,24(sp)
    3174:	01c12083          	lw	ra,28(sp)
    3178:	01412483          	lw	s1,20(sp)
    317c:	01012903          	lw	s2,16(sp)
    3180:	00c12983          	lw	s3,12(sp)
    3184:	00812a03          	lw	s4,8(sp)
    3188:	00060593          	mv	a1,a2
    318c:	02010113          	addi	sp,sp,32
    3190:	9acfe06f          	j	133c <_malloc_r>
    3194:	02061863          	bnez	a2,31c4 <_realloc_r+0x78>
    3198:	818fe0ef          	jal	ra,11b0 <_free_r>
    319c:	00000493          	li	s1,0
    31a0:	01c12083          	lw	ra,28(sp)
    31a4:	01812403          	lw	s0,24(sp)
    31a8:	01012903          	lw	s2,16(sp)
    31ac:	00c12983          	lw	s3,12(sp)
    31b0:	00812a03          	lw	s4,8(sp)
    31b4:	00048513          	mv	a0,s1
    31b8:	01412483          	lw	s1,20(sp)
    31bc:	02010113          	addi	sp,sp,32
    31c0:	00008067          	ret
    31c4:	00050a13          	mv	s4,a0
    31c8:	00058493          	mv	s1,a1
    31cc:	058000ef          	jal	ra,3224 <_malloc_usable_size_r>
    31d0:	00050913          	mv	s2,a0
    31d4:	00856663          	bltu	a0,s0,31e0 <_realloc_r+0x94>
    31d8:	00155793          	srli	a5,a0,0x1
    31dc:	fc87e2e3          	bltu	a5,s0,31a0 <_realloc_r+0x54>
    31e0:	00040593          	mv	a1,s0
    31e4:	000a0513          	mv	a0,s4
    31e8:	954fe0ef          	jal	ra,133c <_malloc_r>
    31ec:	00050993          	mv	s3,a0
    31f0:	00051663          	bnez	a0,31fc <_realloc_r+0xb0>
    31f4:	00098493          	mv	s1,s3
    31f8:	fa9ff06f          	j	31a0 <_realloc_r+0x54>
    31fc:	00040613          	mv	a2,s0
    3200:	00897463          	bgeu	s2,s0,3208 <_realloc_r+0xbc>
    3204:	00090613          	mv	a2,s2
    3208:	00048593          	mv	a1,s1
    320c:	00098513          	mv	a0,s3
    3210:	979fd0ef          	jal	ra,b88 <memcpy>
    3214:	00048593          	mv	a1,s1
    3218:	000a0513          	mv	a0,s4
    321c:	f95fd0ef          	jal	ra,11b0 <_free_r>
    3220:	fd5ff06f          	j	31f4 <_realloc_r+0xa8>

00003224 <_malloc_usable_size_r>:
    3224:	ffc5a783          	lw	a5,-4(a1)
    3228:	ffc78513          	addi	a0,a5,-4
    322c:	0007d863          	bgez	a5,323c <_malloc_usable_size_r+0x18>
    3230:	00a585b3          	add	a1,a1,a0
    3234:	0005a783          	lw	a5,0(a1)
    3238:	00f50533          	add	a0,a0,a5
    323c:	00008067          	ret

00003240 <_write>:
    3240:	ff010113          	addi	sp,sp,-16
    3244:	00112623          	sw	ra,12(sp)
    3248:	00812423          	sw	s0,8(sp)
    324c:	04000893          	li	a7,64
    3250:	00000073          	ecall
    3254:	00050413          	mv	s0,a0
    3258:	00055a63          	bgez	a0,326c <_write+0x2c>
    325c:	40800433          	neg	s0,s0
    3260:	020000ef          	jal	ra,3280 <__errno>
    3264:	00852023          	sw	s0,0(a0)
    3268:	fff00413          	li	s0,-1
    326c:	00c12083          	lw	ra,12(sp)
    3270:	00040513          	mv	a0,s0
    3274:	00812403          	lw	s0,8(sp)
    3278:	01010113          	addi	sp,sp,16
    327c:	00008067          	ret

00003280 <__errno>:
    3280:	1fffd517          	auipc	a0,0x1fffd
    3284:	d8852503          	lw	a0,-632(a0) # 20000008 <_impure_ptr>
    3288:	00008067          	ret
    328c:	3d0a                	fld	fs10,160(sp)
    328e:	3d3d                	jal	30cc <_sbrk_r+0x18>
    3290:	3d3d                	jal	30ce <_sbrk_r+0x1a>
    3292:	3d3d                	jal	30d0 <_sbrk_r+0x1c>
    3294:	3d3d                	jal	30d2 <_sbrk_r+0x1e>
    3296:	3d3d                	jal	30d4 <_sbrk_r+0x20>
    3298:	3d3d                	jal	30d6 <_sbrk_r+0x22>
    329a:	3d3d                	jal	30d8 <_sbrk_r+0x24>
    329c:	3d3d                	jal	30da <_sbrk_r+0x26>
    329e:	3d3d                	jal	30dc <_sbrk_r+0x28>
    32a0:	3d3d                	jal	30de <_sbrk_r+0x2a>
    32a2:	3d3d                	jal	30e0 <_sbrk_r+0x2c>
    32a4:	3d3d                	jal	30e2 <_sbrk_r+0x2e>
    32a6:	3d3d                	jal	30e4 <_sbrk_r+0x30>
    32a8:	3d3d                	jal	30e6 <_sbrk_r+0x32>
    32aa:	3d3d                	jal	30e8 <_sbrk_r+0x34>
    32ac:	3d3d                	jal	30ea <_sbrk_r+0x36>
    32ae:	3d3d                	jal	30ec <_sbrk_r+0x38>
    32b0:	3d3d                	jal	30ee <_sbrk_r+0x3a>
    32b2:	3d3d                	jal	30f0 <_sbrk_r+0x3c>
    32b4:	3d3d                	jal	30f2 <_sbrk_r+0x3e>
    32b6:	0000                	unimp
    32b8:	2020                	fld	fs0,64(s0)
    32ba:	5220                	lw	s0,96(a2)
    32bc:	5349                	li	t1,-14
    32be:	20562d43          	fmadd.s	fs10,fa2,ft5,ft4,rdn
    32c2:	20434f53          	0x20434f53
    32c6:	4e49                	li	t3,18
    32c8:	4554                	lw	a3,12(a0)
    32ca:	5252                	lw	tp,52(sp)
    32cc:	5055                	c.li	zero,-11
    32ce:	2054                	fld	fa3,128(s0)
    32d0:	54535953          	0x54535953
    32d4:	4d45                	li	s10,17
    32d6:	4220                	lw	s0,64(a2)
    32d8:	49544f4f          	fnmadd.s	ft10,fs0,fs5,fs1,rmm
    32dc:	474e                	lw	a4,208(sp)
    32de:	2020                	fld	fs0,64(s0)
    32e0:	0020                	addi	s0,sp,8
    32e2:	0000                	unimp
    32e4:	2020                	fld	fs0,64(s0)
    32e6:	2020                	fld	fs0,64(s0)
    32e8:	2d20                	fld	fs0,88(a0)
    32ea:	4920                	lw	s0,80(a0)
    32ec:	646e                	flw	fs0,216(sp)
    32ee:	7375                	lui	t1,0xffffd
    32f0:	7274                	flw	fa3,100(a2)
    32f2:	2079                	jal	3380 <__errno+0x100>
    32f4:	6e617453          	0x6e617453
    32f8:	6164                	flw	fs1,68(a0)
    32fa:	6472                	flw	fs0,28(sp)
    32fc:	4820                	lw	s0,80(s0)
    32fe:	4c41                	li	s8,16
    3300:	4120                	lw	s0,64(a0)
    3302:	7070                	flw	fa2,100(s0)
    3304:	696c                	flw	fa1,84(a0)
    3306:	6465                	lui	s0,0x19
    3308:	2d20                	fld	fs0,88(a0)
    330a:	2020                	fld	fs0,64(s0)
    330c:	0020                	addi	s0,sp,8
    330e:	0000                	unimp
    3310:	3d3d                	jal	314e <_realloc_r+0x2>
    3312:	3d3d                	jal	3150 <_realloc_r+0x4>
    3314:	3d3d                	jal	3152 <_realloc_r+0x6>
    3316:	3d3d                	jal	3154 <_realloc_r+0x8>
    3318:	3d3d                	jal	3156 <_realloc_r+0xa>
    331a:	3d3d                	jal	3158 <_realloc_r+0xc>
    331c:	3d3d                	jal	315a <_realloc_r+0xe>
    331e:	3d3d                	jal	315c <_realloc_r+0x10>
    3320:	3d3d                	jal	315e <_realloc_r+0x12>
    3322:	3d3d                	jal	3160 <_realloc_r+0x14>
    3324:	3d3d                	jal	3162 <_realloc_r+0x16>
    3326:	3d3d                	jal	3164 <_realloc_r+0x18>
    3328:	3d3d                	jal	3166 <_realloc_r+0x1a>
    332a:	3d3d                	jal	3168 <_realloc_r+0x1c>
    332c:	3d3d                	jal	316a <_realloc_r+0x1e>
    332e:	3d3d                	jal	316c <_realloc_r+0x20>
    3330:	3d3d                	jal	316e <_realloc_r+0x22>
    3332:	3d3d                	jal	3170 <_realloc_r+0x24>
    3334:	3d3d                	jal	3172 <_realloc_r+0x26>
    3336:	3d3d                	jal	3174 <_realloc_r+0x28>
    3338:	003d                	c.nop	15
    333a:	0000                	unimp
    333c:	464e495b          	0x464e495b
    3340:	44205d4f          	0x44205d4f
    3344:	414d                	li	sp,19
    3346:	4d20                	lw	s0,88(a0)
    3348:	6c75646f          	jal	s0,5a20e <_etext+0x56b7e>
    334c:	2065                	jal	33f4 <__errno+0x174>
    334e:	6e45                	lui	t3,0x11
    3350:	6261                	lui	tp,0x18
    3352:	656c                	flw	fa1,76(a0)
    3354:	2064                	fld	fs1,192(s0)
    3356:	2026                	fld	ft0,72(sp)
    3358:	666e6f43          	fmadd.q	ft10,ft8,ft6,fa2,unknown
    335c:	6769                	lui	a4,0x1a
    335e:	7275                	lui	tp,0xffffd
    3360:	6465                	lui	s0,0x19
    3362:	002e                	c.slli	zero,0xb
    3364:	464e495b          	0x464e495b
    3368:	48205d4f          	fnmadd.s	fs10,ft0,ft2,fs1,unknown
    336c:	7261                	lui	tp,0xffff8
    336e:	7764                	flw	fs1,108(a4)
    3370:	7261                	lui	tp,0xffff8
    3372:	2065                	jal	341a <__errno+0x19a>
    3374:	5046                	0x5046
    3376:	2055                	jal	341a <__errno+0x19a>
    3378:	7369                	lui	t1,0xffffa
    337a:	4520                	lw	s0,72(a0)
    337c:	414e                	lw	sp,208(sp)
    337e:	4c42                	lw	s8,16(sp)
    3380:	4445                	li	s0,17
    3382:	002e                	c.slli	zero,0xb
    3384:	464e495b          	0x464e495b
    3388:	50205d4f          	fnmadd.s	fs10,ft0,ft2,fa0,unknown
    338c:	494c                	lw	a1,20(a0)
    338e:	43202c43          	fmadd.d	fs8,ft0,fs2,fs0,rdn
    3392:	494c                	lw	a1,20(a0)
    3394:	544e                	lw	s0,240(sp)
    3396:	2620                	fld	fs0,72(a2)
    3398:	4720                	lw	s0,72(a4)
    339a:	4950                	lw	a2,20(a0)
    339c:	6f43204f          	fnmadd.q	ft0,ft6,fs4,fa3,rdn
    33a0:	666e                	flw	fa2,216(sp)
    33a2:	6769                	lui	a4,0x1a
    33a4:	7275                	lui	tp,0xffffd
    33a6:	6465                	lui	s0,0x19
    33a8:	002e                	c.slli	zero,0xb
    33aa:	0000                	unimp
    33ac:	464e495b          	0x464e495b
    33b0:	47205d4f          	fnmadd.q	fs10,ft0,fs2,fs0,unknown
    33b4:	6f6c                	flw	fa1,92(a4)
    33b6:	6162                	flw	ft2,24(sp)
    33b8:	206c                	fld	fa1,192(s0)
    33ba:	6e49                	lui	t3,0x12
    33bc:	6574                	flw	fa3,76(a0)
    33be:	7272                	flw	ft4,60(sp)
    33c0:	7075                	c.lui	zero,0xffffd
    33c2:	7374                	flw	fa3,100(a4)
    33c4:	4520                	lw	s0,72(a0)
    33c6:	414e                	lw	sp,208(sp)
    33c8:	4c42                	lw	s8,16(sp)
    33ca:	4445                	li	s0,17
    33cc:	2021                	jal	33d4 <__errno+0x154>
    33ce:	74737953          	0x74737953
    33d2:	6d65                	lui	s10,0x19
    33d4:	6920                	flw	fs0,80(a0)
    33d6:	75722073          	csrs	0x757,tp
    33da:	6e6e                	flw	ft8,216(sp)
    33dc:	6e69                	lui	t3,0x1a
    33de:	00002e67          	0x2e67
    33e2:	0000                	unimp
    33e4:	5345545b          	0x5345545b
    33e8:	5d54                	lw	a3,60(a0)
    33ea:	5420                	lw	s0,104(s0)
    33ec:	6972                	flw	fs2,28(sp)
    33ee:	72656767          	0x72656767
    33f2:	6e69                	lui	t3,0x1a
    33f4:	4d442067          	0x4d442067
    33f8:	2041                	jal	3478 <__errno+0x1f8>
    33fa:	7274                	flw	fa3,100(a2)
    33fc:	6e61                	lui	t3,0x18
    33fe:	72656673          	csrrsi	a2,0x726,10
    3402:	2820                	fld	fs0,80(s0)
    3404:	3034                	fld	fa3,96(s0)
    3406:	6220                	flw	fs0,64(a2)
    3408:	7479                	lui	s0,0xffffe
    340a:	7365                	lui	t1,0xffff9
    340c:	2e29                	jal	3726 <_etext+0x96>
    340e:	2e2e                	fld	ft8,200(sp)
    3410:	0000                	unimp
    3412:	0000                	unimp
    3414:	5b0a                	lw	s6,160(sp)
    3416:	4155                	li	sp,21
    3418:	5452                	lw	s0,52(sp)
    341a:	4520                	lw	s0,72(a0)
    341c:	4556                	lw	a0,84(sp)
    341e:	544e                	lw	s0,240(sp)
    3420:	205d                	jal	34c6 <__errno+0x246>
    3422:	6142                	flw	ft2,16(sp)
    3424:	206e                	fld	ft0,216(sp)
    3426:	7576                	flw	fa0,124(sp)
    3428:	2061                	jal	34b0 <__errno+0x230>
    342a:	203a6f67          	0x203a6f67
    342e:	6325                	lui	t1,0x9
    3430:	000a                	c.slli	zero,0x2
    3432:	0000                	unimp
    3434:	3e2d                	jal	2f6e <_reclaim_reent+0x16a>
    3436:	4420                	lw	s0,72(s0)
    3438:	2061                	jal	34c0 <__errno+0x240>
    343a:	6870                	flw	fa2,84(s0)
    343c:	7461                	lui	s0,0xffff8
    343e:	7420                	flw	fs0,104(s0)
    3440:	6e69                	lui	t3,0x1a
    3442:	6820                	flw	fs0,80(s0)
    3444:	6569                	lui	a0,0x1a
    3446:	2075                	jal	34f2 <__errno+0x272>
    3448:	6162                	flw	ft2,24(sp)
    344a:	2074                	fld	fa3,192(s0)
    344c:	454c                	lw	a1,12(a0)
    344e:	2044                	fld	fs1,128(s0)
    3450:	7274                	flw	fa3,100(a2)
    3452:	6e65                	lui	t3,0x19
    3454:	4320                	lw	s0,64(a4)
    3456:	6168                	flw	fa0,68(a0)
    3458:	206e                	fld	ft0,216(sp)
    345a:	2130                	fld	fa2,64(a0)
    345c:	0000                	unimp
    345e:	0000                	unimp
    3460:	3e2d                	jal	2f9a <_fstat_r+0x1a>
    3462:	4420                	lw	s0,72(s0)
    3464:	2061                	jal	34ec <__errno+0x26c>
    3466:	6870                	flw	fa2,84(s0)
    3468:	7461                	lui	s0,0xffff8
    346a:	7420                	flw	fs0,104(s0)
    346c:	6e69                	lui	t3,0x1a
    346e:	6820                	flw	fs0,80(s0)
    3470:	6569                	lui	a0,0x1a
    3472:	2075                	jal	351e <__errno+0x29e>
    3474:	6174                	flw	fa3,68(a0)
    3476:	2074                	fld	fa3,192(s0)
    3478:	454c                	lw	a1,12(a0)
    347a:	2044                	fld	fs1,128(s0)
    347c:	7274                	flw	fa3,100(a2)
    347e:	6e65                	lui	t3,0x19
    3480:	4320                	lw	s0,64(a4)
    3482:	6168                	flw	fa0,68(a0)
    3484:	206e                	fld	ft0,216(sp)
    3486:	2130                	fld	fa2,64(a0)
    3488:	0000                	unimp
    348a:	0000                	unimp
    348c:	5b0a                	lw	s6,160(sp)
    348e:	4d44                	lw	s1,28(a0)
    3490:	2041                	jal	3510 <__errno+0x290>
    3492:	5645                	li	a2,-15
    3494:	4e45                	li	t3,17
    3496:	5d54                	lw	a3,60(a0)
    3498:	4b20                	lw	s0,80(a4)
    349a:	6e65                	lui	t3,0x19
    349c:	2068                	fld	fa0,192(s0)
    349e:	2030                	fld	fa2,64(s0)
    34a0:	6164                	flw	fs1,68(a0)
    34a2:	6320                	flw	fs0,64(a4)
    34a4:	2079706f          	j	9aeaa <_etext+0x9781a>
    34a8:	6f78                	flw	fa4,92(a4)
    34aa:	676e                	flw	fa4,216(sp)
    34ac:	6420                	flw	fs0,72(s0)
    34ae:	2075                	jal	355a <__errno+0x2da>
    34b0:	696c                	flw	fa1,84(a0)
    34b2:	7565                	lui	a0,0xffff9
    34b4:	0021                	c.nop	8
    34b6:	0000                	unimp
    34b8:	3e2d                	jal	2ff2 <_isatty_r+0x26>
    34ba:	4720                	lw	s0,72(a4)
    34bc:	6169                	addi	sp,sp,208
    34be:	7420                	flw	fs0,104(s0)
    34c0:	6972                	flw	fs2,28(sp)
    34c2:	6420                	flw	fs0,72(s0)
    34c4:	615f7473          	csrrci	s0,0x615,30
    34c8:	7272                	flw	ft4,60(sp)
    34ca:	3a5d305b          	0x3a5d305b
    34ce:	2520                	fld	fs0,72(a0)
    34d0:	756c                	flw	fa1,108(a0)
    34d2:	2820                	fld	fs0,80(s0)
    34d4:	7620794b          	fnmsub.q	fs2,ft0,ft2,fa4
    34d8:	3a676e6f          	jal	t3,7987e <_etext+0x761ee>
    34dc:	3120                	fld	fs0,96(a0)
    34de:	0a29                	addi	s4,s4,10
    34e0:	0000                	unimp
    34e2:	0000                	unimp
    34e4:	4349545b          	0x4349545b
    34e8:	31205d4b          	fnmsub.s	fs10,ft0,fs2,ft6,unknown
    34ec:	7320                	flw	fs0,96(a4)
    34ee:	6365                	lui	t1,0x19
    34f0:	20646e6f          	jal	t3,496f6 <_etext+0x46066>
    34f4:	6170                	flw	fa2,68(a0)
    34f6:	64657373          	csrrci	t1,0x646,10
    34fa:	0000                	unimp
    34fc:	464f535b          	0x464f535b
    3500:	5d54                	lw	a3,60(a0)
    3502:	5320                	lw	s0,96(a4)
    3504:	7774666f          	jal	a2,4a47a <_etext+0x46dea>
    3508:	7261                	lui	tp,0xffff8
    350a:	2065                	jal	35b2 <__errno+0x332>
    350c:	6e69                	lui	t3,0x1a
    350e:	6574                	flw	fa3,76(a0)
    3510:	7272                	flw	ft4,60(sp)
    3512:	7075                	c.lui	zero,0xffffd
    3514:	2074                	fld	fa3,192(s0)
    3516:	6572                	flw	fa0,28(sp)
    3518:	76696563          	bltu	s2,t1,3c82 <_etext+0x5f2>
    351c:	6465                	lui	s0,0x19
    351e:	0000                	unimp
    3520:	210a                	fld	ft2,128(sp)
    3522:	2121                	jal	392a <_etext+0x29a>
    3524:	4320                	lw	s0,64(a4)
    3526:	5550                	lw	a2,44(a0)
    3528:	4520                	lw	s0,72(a0)
    352a:	4358                	lw	a4,4(a4)
    352c:	5045                	c.li	zero,-15
    352e:	4954                	lw	a3,20(a0)
    3530:	44204e4f          	0x44204e4f
    3534:	5445                	li	s0,-15
    3536:	4345                	li	t1,17
    3538:	4554                	lw	a3,12(a0)
    353a:	2044                	fld	fs1,128(s0)
    353c:	2121                	jal	3944 <_etext+0x2b4>
    353e:	0021                	c.nop	8
    3540:	434d                	li	t1,19
    3542:	5541                	li	a0,-16
    3544:	203a4553          	0x203a4553
    3548:	7830                	flw	fa2,112(s0)
    354a:	3025                	jal	2d72 <__sseek+0x3a>
    354c:	6c38                	flw	fa4,88(s0)
    354e:	2078                	fld	fa4,192(s0)
    3550:	207c                	fld	fa5,192(s0)
    3552:	454d                	li	a0,19
    3554:	4350                	lw	a2,4(a4)
    3556:	203a                	fld	ft0,392(sp)
    3558:	7830                	flw	fa2,112(s0)
    355a:	3025                	jal	2d82 <__sseek+0x4a>
    355c:	6c38                	flw	fa4,88(s0)
    355e:	0a78                	addi	a4,sp,284
    3560:	0000                	unimp
    3562:	0000                	unimp
    3564:	7245                	lui	tp,0xffff1
    3566:	6f72                	flw	ft10,28(sp)
    3568:	3a72                	fld	fs4,312(sp)
    356a:	4920                	lw	s0,80(a0)
    356c:	6c6c                	flw	fa1,92(s0)
    356e:	6765                	lui	a4,0x19
    3570:	6c61                	lui	s8,0x18
    3572:	4920                	lw	s0,80(a0)
    3574:	736e                	flw	ft6,248(sp)
    3576:	7274                	flw	fa3,100(a2)
    3578:	6375                	lui	t1,0x1d
    357a:	6974                	flw	fa3,84(a0)
    357c:	28206e6f          	jal	t3,97fe <_etext+0x616e>
    3580:	63656843          	fmadd.d	fa6,fa0,fs6,fa2,unknown
    3584:	5046206b          	0x5046206b
    3588:	2f55                	jal	3d3c <_etext+0x6ac>
    358a:	7845                	lui	a6,0xffff1
    358c:	6574                	flw	fa3,76(a0)
    358e:	736e                	flw	ft6,248(sp)
    3590:	6f69                	lui	t5,0x1a
    3592:	736e                	flw	ft6,248(sp)
    3594:	0029                	c.nop	10
    3596:	0000                	unimp
    3598:	7245                	lui	tp,0xffff1
    359a:	6f72                	flw	ft10,28(sp)
    359c:	3a72                	fld	fs4,312(sp)
    359e:	4c20                	lw	s0,88(s0)
    35a0:	2064616f          	jal	sp,497a6 <_etext+0x46116>
    35a4:	6341                	lui	t1,0x10
    35a6:	73736563          	bltu	t1,s7,3cd0 <_etext+0x640>
    35aa:	4620                	lw	s0,72(a2)
    35ac:	7561                	lui	a0,0xffff8
    35ae:	746c                	flw	fa1,108(s0)
    35b0:	2820                	fld	fs0,80(s0)
    35b2:	6e49                	lui	t3,0x12
    35b4:	6176                	flw	ft2,92(sp)
    35b6:	696c                	flw	fa1,84(a0)
    35b8:	2064                	fld	fs1,192(s0)
    35ba:	6552                	flw	fa0,20(sp)
    35bc:	6461                	lui	s0,0x18
    35be:	4120                	lw	s0,64(a0)
    35c0:	6464                	flw	fs1,76(s0)
    35c2:	6572                	flw	fa0,28(sp)
    35c4:	00297373          	csrrci	t1,frm,18
    35c8:	7245                	lui	tp,0xffff1
    35ca:	6f72                	flw	ft10,28(sp)
    35cc:	3a72                	fld	fs4,312(sp)
    35ce:	5320                	lw	s0,96(a4)
    35d0:	6f74                	flw	fa3,92(a4)
    35d2:	6572                	flw	fa0,28(sp)
    35d4:	4120                	lw	s0,64(a0)
    35d6:	73656363          	bltu	a0,s6,3cfc <_etext+0x66c>
    35da:	61462073          	csrs	0x614,a2
    35de:	6c75                	lui	s8,0x1d
    35e0:	2074                	fld	fa3,192(s0)
    35e2:	4928                	lw	a0,80(a0)
    35e4:	766e                	flw	fa2,248(sp)
    35e6:	6c61                	lui	s8,0x18
    35e8:	6469                	lui	s0,0x1a
    35ea:	5720                	lw	s0,104(a4)
    35ec:	6972                	flw	fs2,28(sp)
    35ee:	6574                	flw	fa3,76(a0)
    35f0:	4120                	lw	s0,64(a0)
    35f2:	6464                	flw	fs1,76(s0)
    35f4:	6572                	flw	fa0,28(sp)
    35f6:	00297373          	csrrci	t1,frm,18
    35fa:	0000                	unimp
    35fc:	2b302d23          	sw	s3,698(zero) # 2ba <gpio_set_direction+0x6>
    3600:	0020                	addi	s0,sp,8
    3602:	0000                	unimp
    3604:	6c68                	flw	fa0,92(s0)
    3606:	004c                	addi	a1,sp,4
    3608:	6665                	lui	a2,0x19
    360a:	47464567          	0x47464567
    360e:	0000                	unimp
    3610:	3130                	fld	fa2,96(a0)
    3612:	3332                	fld	ft6,296(sp)
    3614:	3534                	fld	fa3,104(a0)
    3616:	3736                	fld	fa4,360(sp)
    3618:	3938                	fld	fa4,112(a0)
    361a:	4241                	li	tp,16
    361c:	46454443          	fmadd.q	fs0,fa0,ft4,fs0,rmm
    3620:	0000                	unimp
    3622:	0000                	unimp
    3624:	3130                	fld	fa2,96(a0)
    3626:	3332                	fld	ft6,296(sp)
    3628:	3534                	fld	fa3,104(a0)
    362a:	3736                	fld	fa4,360(sp)
    362c:	3938                	fld	fa4,112(a0)
    362e:	6261                	lui	tp,0x18
    3630:	66656463          	bltu	a0,t1,3c98 <_etext+0x608>
    3634:	0000                	unimp
    3636:	0000                	unimp
    3638:	e61c                	fsw	fa5,8(a2)
    363a:	ffff                	0xffff
    363c:	e63c                	fsw	fa5,72(a2)
    363e:	ffff                	0xffff
    3640:	e5e4                	fsw	fs1,76(a1)
    3642:	ffff                	0xffff
    3644:	e5e4                	fsw	fs1,76(a1)
    3646:	ffff                	0xffff
    3648:	e5e4                	fsw	fs1,76(a1)
    364a:	ffff                	0xffff
    364c:	e5e4                	fsw	fs1,76(a1)
    364e:	ffff                	0xffff
    3650:	e63c                	fsw	fa5,72(a2)
    3652:	ffff                	0xffff
    3654:	e5e4                	fsw	fs1,76(a1)
    3656:	ffff                	0xffff
    3658:	e5e4                	fsw	fs1,76(a1)
    365a:	ffff                	0xffff
    365c:	e5e4                	fsw	fs1,76(a1)
    365e:	ffff                	0xffff
    3660:	e5e4                	fsw	fs1,76(a1)
    3662:	ffff                	0xffff
    3664:	e81c                	fsw	fa5,16(s0)
    3666:	ffff                	0xffff
    3668:	e694                	fsw	fa3,8(a3)
    366a:	ffff                	0xffff
    366c:	e7a0                	fsw	fs0,72(a5)
    366e:	ffff                	0xffff
    3670:	e5e4                	fsw	fs1,76(a1)
    3672:	ffff                	0xffff
    3674:	e5e4                	fsw	fs1,76(a1)
    3676:	ffff                	0xffff
    3678:	e864                	fsw	fs1,84(s0)
    367a:	ffff                	0xffff
    367c:	e5e4                	fsw	fs1,76(a1)
    367e:	ffff                	0xffff
    3680:	e694                	fsw	fa3,8(a3)
    3682:	ffff                	0xffff
    3684:	e5e4                	fsw	fs1,76(a1)
    3686:	ffff                	0xffff
    3688:	e5e4                	fsw	fs1,76(a1)
    368a:	ffff                	0xffff
    368c:	e7ac                	fsw	fa1,72(a5)
    368e:	ffff                	0xffff
