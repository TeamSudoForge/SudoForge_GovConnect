import { Module } from '@nestjs/common';
import { RelyingPartyService } from './relying-party.service';

@Module({
  providers: [RelyingPartyService],
  exports: [RelyingPartyService],
})
export class RelyingPartyModule {}
