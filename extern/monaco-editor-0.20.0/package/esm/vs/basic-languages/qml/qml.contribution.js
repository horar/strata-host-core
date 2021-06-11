'use strict';
import { registerLanguage } from '../_.contribution.js';
registerLanguage({ 
    id: 'qml' ,
    extensions:[".qml"],
    aliases: ["qml","QML"],
    loader: function () { return import('./qml.js'); }
})