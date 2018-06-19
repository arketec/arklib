package.path = package.path .. ';/home/arklib/'
return {
    util = {
        try = require('src.util.try')
    },
    constants = {
        colors = require('src.constants.myColors'),
    },
    ui = {
        button = require('src.ui.button'),
        bars = require('src.ui.bars'),
        input = require('src.ui.input'),
        window = require('src.ui.window')
    }
}