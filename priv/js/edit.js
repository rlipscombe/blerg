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
    var id = $('#id').val();
    var title = $('#title').val();
    var markdown = editor.getValue();

    // TODO: Why are we still copying this into the hidden field?
    $('input[name=markdown]').val(markdown);

    var data = {
        id: id,
        title: title,
        markdown: markdown
    };

    $('#do-save').prop('disabled', true);
    $.ajax('/post/save', {
        type: 'POST',
        data: data,
        success: function(data, status, xhr) {
            // TODO: Some kind of splash -- saved.
            $('input[name=id]').val(data.id);
        },
        error: function(xhr, status, err) {
            // TODO: Some kind of splash -- failed.
        },
        complete: function(xhr, status) {
            $('#do-save').prop('disabled', false);
        }
    });
    return false;    // false => don't actually post the form.
}

$(document).ready(function() {
    $('#go-preview').click(goPreview);
    $('#go-edit').click(goEdit);
    $('#do-save').click(doSave);

    editor.setTheme('ace/theme/textmate');
    editor.getSession().setMode('ace/mode/markdown');
    
    goEdit();
});
