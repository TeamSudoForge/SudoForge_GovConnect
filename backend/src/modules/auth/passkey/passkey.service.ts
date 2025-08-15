import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  generateRegistrationOptions,
  verifyRegistrationResponse,
  generateAuthenticationOptions,
  verifyAuthenticationResponse,
  AuthenticatorTransportFuture,
} from '@simplewebauthn/server';
import { Passkey } from './entities/passkey.entity';
import { User } from '../../../database/entities/user.entity';
import {
  RegisterPasskeyFinishDto,
  AuthenticatePasskeyFinishDto,
  AuthenticatePasskeyStartDto,
} from './dto/passkey.dto';
import { RelyingPartyService } from 'src/relying-party/relying-party.service';

@Injectable()
export class PasskeyService {
  constructor(
    @InjectRepository(Passkey)
    private readonly passkeyRepository: Repository<Passkey>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly relyingPartyService: RelyingPartyService,
  ) {}

  async generateRegistrationOptions(userId: string) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const options = await generateRegistrationOptions({
      rpName: this.relyingPartyService.name,
      rpID: this.relyingPartyService.id,
      userID: user.id as typeof generateRegistrationOptions.arguments.user_id,
      userName: user.username,
      attestationType: 'none',
      excludeCredentials: [],
      authenticatorSelection: {
        residentKey: 'required',
        userVerification: 'preferred',
      },
    });

    user.passkeyChallenge = options.challenge;
    await this.userRepository.save(user);

    return options;
  }

  async verifyRegistration(
    userId: string,
    body: RegisterPasskeyFinishDto,
  ) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const expectedChallenge = user.passkeyChallenge;

    const verification = await verifyRegistrationResponse({
      response: body,
      expectedChallenge: expectedChallenge as string,
      expectedOrigin: this.relyingPartyService.origin,
      expectedRPID: this.relyingPartyService.id,
      requireUserVerification: true,
    });

    if (verification.verified && verification.registrationInfo) {
      const {
        credential: { publicKey, id, counter },
      } = verification.registrationInfo;

      const newPasskey = this.passkeyRepository.create({
        userId,
        credentialId: Buffer.from(id).toString('base64url'),
        publicKey: Buffer.from(publicKey).toString('base64url'),
        counter,
      });

      await this.passkeyRepository.save(newPasskey);
      user.passkeyChallenge = null;
      await this.userRepository.save(user);

      return { verified: true };
    }

    return { verified: false };
  }

  async generateAuthenticationOptions(username: string) {
    const user = await this.userRepository.findOne({ where: { username } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const userPasskeys = await this.passkeyRepository.find({
      where: { userId: user.id },
    });
    const options = await generateAuthenticationOptions({
      rpID: this.relyingPartyService.id,
      allowCredentials: userPasskeys.map((passkey) => ({
        id: passkey.credentialId,
        transports: passkey.transports as AuthenticatorTransportFuture[],
      })),
      userVerification: 'preferred',
    });

    user.passkeyChallenge = options.challenge;
    await this.userRepository.save(user);

    return options;
  }

  async verifyAuthentication(
    username: string,
    body: AuthenticatePasskeyFinishDto,
  ) {
    const user = await this.userRepository.findOne({ where: { username } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const passkey = await this.passkeyRepository.findOne({
      where: {
        credentialId: body.rawId,
        userId: user.id,
      },
    });

    if (!passkey) {
      throw new NotFoundException('Passkey not found');
    }

    const expectedChallenge = user.passkeyChallenge;

const verification = await verifyAuthenticationResponse({
  response: body,
  expectedChallenge: expectedChallenge as string,
  expectedOrigin: this.relyingPartyService.origin,
  expectedRPID: this.relyingPartyService.id,
  requireUserVerification: true,
  credential: {
    id: passkey.credentialId,
    publicKey: Buffer.from(passkey.publicKey, 'base64url'),
    counter: passkey.counter,
    transports: passkey.transports as AuthenticatorTransportFuture[],
  },
});

    if (verification.verified) {
      passkey.counter = verification.authenticationInfo.newCounter;
      await this.passkeyRepository.save(passkey);
      user.passkeyChallenge = null;
      await this.userRepository.save(user);
    }

    return { verified: verification.verified, user };
  }
}
