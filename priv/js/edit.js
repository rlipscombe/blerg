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
    var title = $('#title').val();
    var markdown = editor.getValue();
    $('input[name=markdown]').val(markdown);
    var data = {
        title: title,
        markdown: markdown
    };

    $('#do-save').prop('disabled', true);
    $.ajax('/post/save', {
        type: 'POST',
        data: data,
        success: function(data, status, xhr) {
            console.log(data);
            console.log(status);
        },
        error: function(xhr, status, err) {
            console.log(status);
            console.log(err);
        },
        complete: function(xhr, status) {
            console.log(status);
            $('#do-save').prop('disabled', false);
        }
    });
    return false;    // false => don't actually post the form.
}

$(document).ready(function() {
    $('#go-preview').click(goPreview);
    $('#go-edit').click(goEdit);

    goEdit();

    $('#do-save').click(doSave);

    editor.setTheme('ace/theme/textmate');
    editor.getSession().setMode('ace/mode/markdown');
});

