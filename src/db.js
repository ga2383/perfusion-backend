import pkg from '@prisma/client';
const { PrismaClient } = pkg;

let prisma;
if (!global.__prisma) {
  global.__prisma = new PrismaClient();
}
prisma = global.__prisma;

export default prisma;
