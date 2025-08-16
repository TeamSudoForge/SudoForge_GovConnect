import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { InjectRepository } from '@nestjs/typeorm';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { Repository } from 'typeorm';
import { User } from '../../database/entities';
import { Department } from '../../modules/forms/entities/department.entity';

export interface JwtPayload {
  sub: string;
  username?: string;
  email: string;
  role?: string;
  type?: 'user' | 'department';
}

export interface AuthUser {
  id?: string;
  department_id?: number;
  username?: string;
  email: string;
  role?: string;
  type: 'user' | 'department';
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Department)
    private departmentRepository: Repository<Department>,
    private configService: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get('jwt.secret') || 'fallback-secret',
    });
  }

  async validate(payload: JwtPayload): Promise<AuthUser> {
    // Check if this is a department token
    if (payload.type === 'department') {
      const department = await this.departmentRepository.findOne({
        where: { department_id: parseInt(payload.sub) },
      });

      if (!department || !department.isActive) {
        throw new UnauthorizedException('INVALID_TOKEN');
      }

      return {
        department_id: department.department_id,
        email: department.email,
        role: department.role,
        type: 'department',
      };
    }

    // Handle regular user tokens
    const user = await this.userRepository.findOne({
      where: { id: payload.sub },
    });

    if (!user) {
      throw new UnauthorizedException('INVALID_TOKEN');
    }

    return {
      id: user.id,
      username: user.username,
      email: user.email,
      type: 'user',
    };
  }
}
