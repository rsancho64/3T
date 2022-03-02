# reimplementamos.
# https://levelup.gitconnected.com/build-an-express-api-with-sequelize-cli-and-express-router-963b6e274561

rm -Rf .git*
git init
echo "
/node_modules
.env" > .gitignore

rm -Rf node_modules
rm  -f package.json
npm init -y
npm install --save sequelize pg
npm install -D mysql2 sequelize-cli
npm install -D nodemon 

rm -Rf config/ migrations/ seeders/ models/
rm -Rf routes/ controllers/

npx sequelize-cli init

cat << PACKAGE.JSON > package.json
{
  "name": "3tjuegos",
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
    "body-parser": "^1.19.2",
    "express": "^4.17.3",
    "pg": "^8.7.3",
    "sequelize": "^6.17.0"
  },
  "devDependencies": {
    "mysql2": "^2.3.3",
    "nodemon": "^2.0.15",
    "sequelize-cli": "^6.4.1"
  }
}
PACKAGE.JSON

cat << CONFIG..CONFIG.JSON > config/config.json
{
  "development": {
    "username": "root",
    "password": "bea",
    "database": "projects_api_development",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "test": {
    "username": "root",
    "password": "bea",
    "database": "projects_api_test",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "production": {
    "username": "root",
    "password": null,
    "database": "database_production",
    "host": "127.0.0.1",
    "dialect": "mysql"
  }
}
CONFIG..CONFIG.JSON

mysql -u root -pbea -e "drop database if exists projects_api_development;"

npx sequelize-cli db:create

# models n seed data

# model user ----------------------------------------------------------
npx sequelize-cli model:generate --name user \
 --attributes firstName:string,lastName:string
#--attributes firstName:string,lastName:string,email:string,password:string

npx sequelize-cli db:migrate

#npx sequelize-cli seed:generate --name users
cat << SEEDERS..0-USERS.JS > seeders/0-users.js
module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('users', [
    {
      firstName: 'John', lastName: 'Doe',
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      firstName: 'John', lastName: 'Smith',
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      firstName: 'John', lastName: 'Stone',
      createdAt: new Date(), updatedAt: new Date()
    }], {});
  },
  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('users', null, {});
  }
};
SEEDERS..0-USERS.JS

npx sequelize-cli db:seed --seed seeders/0-users.js

# model project ----------------------------------------------------------
npx sequelize-cli model:generate --name project \
  --attributes userId:integer,title:string
##--attributes userId:integer,title:string,imageUrl:string,description:text,

rm migrations/*project.js # rm migrador automatico: lo ajustamos:

cat << MIGRATIONS/0-CREATE-PROJECT.JS > migrations/0-create-project.js
'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('projects', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      userId: {
        type: Sequelize.INTEGER,
        onDelete: 'CASCADE',  // new ..
        references: {
          model: 'users',
          key: 'id',
          as: 'userId',
        }                     // .. new
      },
      title: {
        type: Sequelize.STRING
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
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('projects');
  }
};
MIGRATIONS/0-CREATE-PROJECT.JS

# ajustamos el modelo projecto: tiene fk to user
cat << MODELS..PROJECT.JS > models/project.js
'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class project extends Model {
    static associate(models) {              // new ...
      project.belongsTo(models.user, {
        foreignKey: 'userId',
        onDelete: 'CASCADE'
      })
    }                                       // ... new
  }
  project.init({
    userId: DataTypes.INTEGER,
     title: DataTypes.STRING     
  }, {
    sequelize,
    modelName: 'project',
  });
  return project;
};
MODELS..PROJECT.JS

# ajustamos el modelo user: vinculo hasMany a project
cat << MODELS..USER.JS > models/user.js
'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class user extends Model {
    static associate(models) {
      user.hasMany(models.project, {  // new ...
        foreignKey: 'userId'
      })                              // ... new
    }
  }
  user.init({
    firstName: DataTypes.STRING,
    lastName: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'user',
  });
  return user;
};
MODELS..USER.JS

npx sequelize-cli db:migrate

#npx sequelize-cli seed:generate --name projects # no automatico: manual:
cat << SEEDERS..0-PROJECTS.JS > seeders/0-projects.js
module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('projects', [
    {
      title: 'prj1',
      userId: 1,
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      title: 'prj2',
      userId: 3,
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      title: 'prj3',
      userId: 2,
      createdAt: new Date(), updatedAt: new Date()
    },
    {
      title: 'prj4',
      userId: 1,
      createdAt: new Date(), updatedAt: new Date()
    }
    ], {});
  },
  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('projects', null, {});
  }
};
SEEDERS..0-PROJECTS.JS

npx sequelize-cli db:seed --seed seeders/0-projects.js

mysql -u root -pbea -e "
use projects_api_development;
show tables;
-- select * from users;
select id, lastName from users;
-- select * from projects;
select id, userID, title from projects;
-- select * from users JOIN projects ON users.id = projects.userId;
"

# ++ express, rutes,.. ##############################################

npm install --save express body-parser 
npm install -D nodemon

mkdir routes controllers
touch server.js routes/index.js controllers/index.js

cat << PACKAGE.JSON > package.json
{
  "name": "3t",
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
    "pg": "^8.7.3",
    "sequelize": "^6.17.0"
  },
  "devDependencies": {
    "mysql2": "^2.3.3",
    "nodemon": "^2.0.15",
    "sequelize-cli": "^6.4.1"
  }
}
PACKAGE.JSON

cat << SERVER.JS > server.js
const    express = require('express');
const     routes = require('./routes');
const bodyParser = require('body-parser')
const PORT = process.env.PORT || 3000;
const app = express();
app.use(bodyParser.json())
app.use('/api', routes);
app.listen(PORT, () => console.log("listening on port: ", '${PORT}'))
SERVER.JS

cat << ROUTES..INDEX.JS > routes/index.js
const { Router } = require('express');
const controllers = require('../controllers');
const router = Router();
router.get( '/', (req, res) => res.send('This is root!'))
router.post('/users', controllers.createUser)
router.get( '/users', controllers.getAllUsers)
module.exports = router
ROUTES..INDEX.JS

cat << CONTROLLERS.INDEX.JS > controllers/index.js
const { user } = require('../models');
const { project } = require('../models');
const createUser = async (req, res) => {
    try {
        const user = await user.create(req.body);
        return res.status(201).json({
            user,
        });
    } catch (error) {
        return res.status(500).json({ error: error.message })
    }
}

const getAllUsers = async (req, res) => {
    try {
        const users = await user.findAll({
            include: [
                {
                    model: project
                }
            ]
        });
        return res.status(200).json({ users });
    } catch (error) {
        return res.status(500).send(error.message);
    }
}
module.exports = {
    createUser,
    getAllUsers
}
CONTROLLERS.INDEX.JS

echo "BYE--"
exit 0 # ###########################################################
