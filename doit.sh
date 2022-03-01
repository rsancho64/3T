# bash script
# recipe: https://levelup.gitconnected.com/build-an-express-api-with-sequelize-cli-and-express-router-963b6e274561

rm  -f package* 
rm -Rf config/ migrations/ models/ controllers/ seeders/ routes/
sync 

# rm -Rf .git* 
echo "
/node_modules
.DS_Store
.env" >> .gitignore
git init

#rm -Rf node_modules
npm init -y
npm install --save mysql2 sequelize pg
npm install -D sequelize-cli
npm install -D nodemon 
npm install --save body-parser # to handle info from user requests
npm install --save express 

npx sequelize-cli init

cat << CONFIG..CONFIG.JSON > config/config.json
{
  "development": {
  "username": "root",
  "password": "bea",
	"database": "3T",
	"host": "127.0.0.1",
	"dialect": "mysql"
  },

  "test": {
    "database": "pp_api_test",
    "dialect":  "mysql"
  },

  "production": {
    "use_env_variable": "DATABASE_URL",
    "dialect": "mysql",
    "dialectOptions": {
      "ssl": {
        "rejectUnauthorized": false
      }
    }
  }
}
CONFIG..CONFIG.JSON

# DB ----------------

mysql -u root -pbea -e "drop database if exists 3T;"
npx sequelize-cli db:create

# models n seed data ---------------- 

## Models:

## models: Cliente y Vehiculo

npx sequelize-cli model:generate --name cliente \
--attributes firstName:string,lastName:string #,email:string,password:string

npx sequelize-cli model:generate --name vehiculo \
--attributes modelo:string,anio:string,color:string

#npx sequelize-cli seed:generate --name clientes
cat << SEEDERS..0.CLIENTES.JS > seeders/0-clientes.js
module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('clientes', [{
      firstName: 'John', lastName:  'Doe',
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      firstName: 'John', lastName:  'Smith',
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      firstName: 'John', lastName:  'Stone',
      createdAt: new Date(), updatedAt: new Date()
    }], {});
  },  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('clientes', null, {});
  }
};
SEEDERS..0.CLIENTES.JS

# npx sequelize-cli seed:generate --name vehiculos
cat << SEEDERS..0.VEHICULOS.JS > seeders/0-vehiculos.js
module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('vehiculos', [
    {
      modelo: 'Audi', anio: '2004', color: 'negro',
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      modelo: 'BMW', anio: '2010', color: 'blanco',
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      modelo: 'MB', anio: '2018', color: 'negro',
      createdAt: new Date(), updatedAt: new Date()
    }
    ], {});
  },  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('vehiculos', null, {});
  }
};
SEEDERS..0.VEHICULOS.JS

npx sequelize-cli db:migrate
# npx sequelize-cli db:seed:all  # mas tarde ...

## Venta model:
npx sequelize-cli model:generate --name venta \
--attributes clienteId:integer,vehiculoId:integer
# npx sequelize-cli db:migrate

# vinculamos vehiculos a ventas:
# cat << MODELS..VEHICULO.JS > models/vehiculo.js
# 'use strict';
# const {
#   Model
# } = require('sequelize');

# module.exports = (sequelize, DataTypes) => {
#   const Venta = sequelize.define('Venta', {
#     vehiculoId:      DataTypes.INTEGER
#   }, {});

#   Venta.associate = function (models) {

#     Venta.belongsTo(models.Vehiculo, {
#       foreignKey: 'vehiculoId',
#       onDelete: 'CASCADE'
#     })

#   };
#   return Venta;
# };
# MODELS..VEHICULO.JS

cat << MODELS..VENTA.JS > models/venta.js
'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class venta extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {

      // define association here

      venta.belongsTo(models.cliente,     // new ...
        {
            as: 'cliente',
            foreignKey: 'clienteId',
        }
      );
      venta.belongsTo(models.juego,
        {
            as: 'vehiculo',
            foreignKey: 'vehiculoId',
        }
      );                                // ... new
    }
  }
  venta.init({
    clienteId:  DataTypes.INTEGER,
    vehiculoId: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'venta',
  });
  return venta;
};
MODELS..VENTA.JS

#npx sequelize-cli seed:generate --name ventas

rm migrations/*-create-venta.js # !!!!!!!

cat << MIGRATIONS..0-CREATE-VENTA.JS > migrations/0-create-venta.js
'use strict';
module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.createTable('ventas', {

      id: {
        allowNull:     false,
        autoIncrement: true,
        primaryKey:    true,
        type: Sequelize.INTEGER
      },

      clienteId: {
        type: Sequelize.INTEGER,
        onDelete: 'CASCADE',
        references: {
          model: 'clientes',
          key:   'id',
          as:    'clienteId',
        }
      },

      vehiculoId: {
        type: Sequelize.INTEGER,
        onDelete: 'CASCADE',
        references: {
          model: 'vehiculos',
          key:   'id',
          as:    'vehiculoId',
        }
      },

      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },

      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }

    });
  },
  down: (queryInterface, Sequelize) => {
    return queryInterface.dropTable('ventas');
  }
};
MIGRATIONS..0-CREATE-VENTA.JS

npx sequelize-cli db:migrate

# npx sequelize-cli seed:generate --name ventas
cat << SEEDERS..0.VENTAS.JS > seeders/0-ventas.js
module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('ventas', [{
      clienteId:  1, vehiculoId: 1,
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      clienteId:  3, vehiculoId: 1,      
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      clienteId:  2, vehiculoId: 2,
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      clienteId:  1, vehiculoId: 1,
      createdAt: new Date(), updatedAt: new Date()
    }], {});
  },  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('ventas', null, {});
  }
};
SEEDERS..0.VENTAS.JS

npx sequelize-cli db:seed:all

# test seeding:
mysql -u root -pbea -e "\

use 3T;
SELECT id, firstName , lastName FROM clientes;
SELECT id, modelo, anio, color  FROM vehiculos;
SELECT id, clienteId  FROM ventas ORDER BY id;
SELECT id, vehiculoId FROM ventas ORDER BY id;

SELECT * 
FROM ventas JOIN clientes 
ON ventas.clienteId = clientes.id
ORDER BY ventas.id;
-- 
SELECT ventas.id as 'v.id', ventas.clienteID as 'fk', clientes.id as 'cl.id'
FROM ventas JOIN clientes 
ON ventas.clienteId = clientes.id
ORDER BY ventas.id;
--
SELECT *
FROM ventas JOIN vehiculos
ON ventas.vehiculoId = vehiculos.id
ORDER BY ventas.id;
--
SELECT ventas.id as 'v.id', ventas.vehiculoID as 'fk', vehiculos.id as 'veh.id'
FROM ventas JOIN vehiculos
ON ventas.vehiculoId = vehiculos.id
ORDER BY ventas.id;
--
--
"
# use Express; set up routes ------------------------------------------

mkdir routes controllers
touch server.js  routes/index.js controllers/index.js

# update package.json
cat << PACKAGE.JSON > package.json
{
  "name": "exp-api",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "nodemon server.js",
    "db:reset": "npx sequelize-cli db:drop && npx sequelize-cli db:create && npx sequelize-cli db:migrate && npx sequelize-cli db:seed:all"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "body-parser": "^1.19.1",
    "express": "^4.17.2",
    "mysql2": "^2.3.3",
    "pg": "^8.7.3",
    "sequelize": "^6.16.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.15",
    "sequelize-cli": "^6.4.1"
  }
}
PACKAGE.JSON

cat << ROUTES..INDEX.JS > routes/index.js
const { Router } = require('express');
const controllers = require('../controllers');
const router = Router();

router.get( '/', (req, res) => res.send('HOME! '))
router.post('/clientes', controllers.createCliente)

module.exports = router
ROUTES..INDEX.JS

cat << SERVER.JS > server.js
const    express = require('express');
const     routes = require('./routes');
const bodyParser = require('body-parser')

const PORT = process.env.PORT || 3000;
const  app = express();
app.use(bodyParser.json());
app.use('/api', routes);
app.listen(PORT, () => console.log('escucha en puerto' , PORT))
SERVER.JS

cat << CONTROLLERS..INDEX.JS > controllers/index.js
const { Cliente } = require('../models');

const createCliente = async (req, res) => {
    try {
        const cliente = await Cliente.create(req.body);
        return res.status(201).json({
            cliente,
        });
    } catch (error) {
        return res.status(500).json({ error: error.message })
    }
}

module.exports = {
    createCliente
}
CONTROLLERS..INDEX.JS

# echo "BYE----" && exit 0 
## ###############################################################
