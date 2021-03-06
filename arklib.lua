package.path = package.path .. ';/home/lib/arklib/'
return {
    util = {
        try = require('src.util.try'),
        file = require('src.util.file'),
        string = require('src.util.string')
    },
    constants = {
        colors = require('src.constants.myColors'),
    },
    tools = {
        painter = require('src.tools.wysiwyg_painter')
    },
    networking = {
        server = require('src.networking.server'),
        client = require('src.networking.client')
    },
    ui = {
        button = require('src.ui.button'),
        bars = require('src.ui.bars'),
        input = require('src.ui.input'),
        window = require('src.ui.window')
    },
    text = {
        letters = require('src.text.letters'),
        large = require('src.text.large')
    }
}