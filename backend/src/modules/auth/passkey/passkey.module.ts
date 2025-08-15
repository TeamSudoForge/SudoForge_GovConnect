import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PasskeyService } from './passkey.service';
import { PasskeyController } from './passkey.controller';
import { Passkey } from './entities/passkey.entity';
import { User } from '../../users/entities/user.entity';
import { RelyingPartyModule } from 'src/relying-party/relying-party.module';
import { AuthModule } from '../auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Passkey, User]),
    RelyingPartyModule,
    AuthModule,
  ],
  providers: [PasskeyService],
  controllers: [PasskeyController],
})
export class PasskeyModule {}
