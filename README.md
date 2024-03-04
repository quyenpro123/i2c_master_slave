# I2C Master module (1 master - 1 slave)
## I. Wave Form 
### 1. Start, Stop, Repeat start condition
![condition wave](/Spec_condition.png)
### 2. Read, Write
![Read/Write wave](/Read_write_wave.png)
## II. Specification
### 1. Block diagram
![Master block diagram](/master%20_lock.png)
### 2. FSM
![FSM Master](/fsm_master.png)
### 3. Register map and APB slave interface
#### a. Register list
|NAME|ADDRESS|WIDTH|ACCESS|DESCRIPTION|
|:----:|:---:|:---:|:----:|:------|
|prescaler|0x00|8|RW|equal to i2c_core_clock / scl_clock| 
|cmd|0x01|8|RW|command from cpu to i2c core|
|transmit|0x02|8|R|save data from cpu to master for transfer to slave|
|receive|0x03|8|R|save data in from slave to master|
|address_rw|0x04|8|RW|address of slave and read write bit cpu send to i2c master|
|status|0x05|8|R|status of fifo, bus,...| 
#### b. 
## III. Simulation
## IV. User Guild


