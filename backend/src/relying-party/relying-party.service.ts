import { Injectable } from '@nestjs/common';

@Injectable()
export class RelyingPartyService {
  get id() {
    return 'localhost';
  }

  get name() {
    return 'GovConnect';
  }

  get origin() {
    return 'http://localhost:3000';
  }
}
