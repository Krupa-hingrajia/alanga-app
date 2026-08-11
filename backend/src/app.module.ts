import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import configuration from './config/configuration';
import { DatabaseModule } from './database/database.module';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { VendorDashboardModule } from './modules/vendor-dashboard/vendor-dashboard.module';
import { AdminAuthModule } from './modules/admin-auth/admin-auth.module';
import { AdminDashboardModule } from './modules/admin-dashboard/admin-dashboard.module';
import { CategoriesModule } from './modules/master-data/categories/categories.module';
import { SubCategoriesModule } from './modules/master-data/sub-categories/sub-categories.module';
import { BrandsModule } from './modules/master-data/brands/brands.module';
import { UnitsModule } from './modules/master-data/units/units.module';
import { AttributesModule } from './modules/master-data/attributes/attributes.module';
import { AttributeValuesModule } from './modules/master-data/attribute-values/attribute-values.module';
import { ProductsModule } from './modules/products/products.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: `.env.${process.env.NODE_ENV || 'development'}`,
      load: [configuration],
    }),
    DatabaseModule,
    UsersModule,
    AuthModule,
    VendorDashboardModule,
    AdminAuthModule,
    AdminDashboardModule,
    CategoriesModule,
    SubCategoriesModule,
    BrandsModule,
    UnitsModule,
    AttributesModule,
    AttributeValuesModule,
    ProductsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
