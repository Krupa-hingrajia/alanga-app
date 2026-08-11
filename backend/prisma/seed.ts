import { PrismaClient, Role, UserStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const adminEmail = 'admin@alanga.com';
  const existingAdmin = await prisma.user.findUnique({
    where: { email: adminEmail },
  });

  if (!existingAdmin) {
    const hashedPassword = bcrypt.hashSync('AdminPassword123!', 10);
    await prisma.user.create({
      data: {
        fullName: 'Admin User',
        email: adminEmail,
        countryCode: '+91',
        mobileNumber: '9999999999',
        password: hashedPassword,
        role: Role.ADMIN,
        status: UserStatus.ACTIVE,
      },
    });
    console.log('Default admin user created successfully.');
  } else {
    console.log('Admin user already exists.');
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
