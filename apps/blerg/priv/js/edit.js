/* global $:false, document:false, ace:false */
var editor = ace.edit('editor');

function goEdit() {
    $('#go-edit').addClass('active');
    $('#tab-edit').show();

    $('#go-preview').removeClass('active');
    $('#tab-preview').hide();
}

function goPreview() {
    $('#go-preview').addClass('active');
    $('#tab-preview').show();

    $('#go-edit').removeClass('active');
    $('#tab-edit').hide();
}

function doSave() {
    var markdown = editor.getValue();
    $('input[name=markdown]').val(markdown);
    return true;    // true => actually post the form.
}

$(document).ready(function() {
    $('#go-preview').click(goPreview);
    $('#go-edit').click(goEdit);

    goEdit();

    $('#do-save').click(doSave);

    editor.setTheme('ace/theme/textmate');
    editor.getSession().setMode('ace/mode/markdown');
});

