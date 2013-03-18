describe('Normalize', ->
  describe('breakLine', ->
    blockTest = new Scribe.Test.HtmlTest((container) ->
      Scribe.Normalizer.breakLine(container.firstChild, container)
    )

    blockTest.run('Inner divs', [
      '<div>
        <div><span>One</span></div>
        <div><span>Two</span></div>
      </div>'
    ], [
      '<div><span>One</span></div>'
      '<div><span>Two</span></div>'
    ])

    blockTest.run('Nested inner divs', [
      '<div>
        <div><div><span>One</span></div></div>
        <div><div><span>Two</span></div></div>
      </div>'
    ], [
      '<div><span>One</span></div>'
      '<div><span>Two</span></div>'
    ])
  )

  describe('normalizeBreak', ->
    breakTest = new Scribe.Test.HtmlTest((container) ->
      Scribe.Normalizer.normalizeBreak(container.querySelector('br'), container)
    )

    breakTest.run('Break in middle of line', [
      '<div><b>One<br />Two</b></div>'
    ], [
      '<div><b>One</b></div>'
      '<div><b>Two</b></div>'
    ])

    breakTest.run('Break preceding line', [
      '<div><b><br />One</b></div>'
    ], [
      '<div><b><br /></b></div>'
      '<div><b>One</b></div>'
    ])

    breakTest.run('Break after line', 
      ['<div><b>One<br /></b></div>'], 
      ['<div><b>One</b></div>']
    )
  )

  describe('groupBlocks', ->
    groupTest = new Scribe.Test.HtmlTest((container) ->
      Scribe.Normalizer.groupBlocks(container)
    )

    groupTest.run('Wrap newline', 
      ['<br />'], 
      ['<div><br /></div>']
    )

    groupTest.run('Wrap span', 
      ['<span>One</span>'], 
      ['<div><span>One</span></div>']
    )

    groupTest.run('Wrap many spans', [
      '<div><span>One</span></div>'
      '<span>Two</span>'
      '<span>Three</span>'
      '<div><span>Four</span></div>'
    ], [
      '<div><span>One</span></div>'
      '<div><span>Two</span><span>Three</span></div>'
      '<div><span>Four</span></div>'
    ])

    groupTest.run('Wrap break and span', 
      ['<br /><span>One</span>'], 
      ['<div><br /><span>One</span></div>']
    )
  )

  describe('normalizeLine', ->
    lineTest = new Scribe.Test.LineTest((lineNode) ->
      Scribe.Normalizer.normalizeLine(lineNode)
    )

    lineTest.run('tranform equivalent styles', [
      '<strong>Strong</strong>
        <del>Deleted</del>
        <em>Emphasis</em>
        <strike>Strike</strike>
        <b>Bold</b>
        <i>Italic</i>
        <s>Strike</s>
        <u>Underline</u>'
    ], [
      '<b>Strong</b>
        <s>Deleted</s>
        <i>Emphasis</i>
        <s>Strike</s>
        <b>Bold</b>
        <i>Italic</i>
        <s>Strike</s>
        <u>Underline</u>'
    ])

    lineTest.run('merge adjacent equal nodes', 
      '<b>Bold1</b><b>Bold2</b>', 
      '<b>Bold1Bold2</b></div>'
    )

    lineTest.run('merge adjacent equal spans',
      '<span class="color-red">
        <span class="background-blue">Red1</span>
      </span>
      <span class="color-red">
        <span class="background-blue">Red2</span>
      </span>',
      '<span class="color-red">
        <span class="background-blue">Red1Red2</span>
      </span>'
    )

    lineTest.run('do not merge adjacent unequal spans',
      '<span class="size-huge">Huge</span>
      <span class="size-large">Large</span>',
      '<span class="size-huge">Huge</span>
      <span class="size-large">Large</span>'
    )

    lineTest.run('remove redundant format elements', 
      '<b><i><b>Bolder</b></i></b>', 
      '<b><i>Bolder</i></b>'
    )

    lineTest.run('remove redundant elements 1', 
      '<span><br></span>', 
      '<br />'
    )

    lineTest.run('remove redundant elements 2', 
      '<span><span>Span</span></span>', 
      '<span>Span</span>'
    )

    lineTest.run('wrap text node', 
      'Hey', 
      '<span>Hey</span>'
    )

    lineTest.run('wrap text node next to element node', 
      'Hey<b>Bold</b>',
      '<span>Hey</span><b>Bold</b>'
    )
  )

  describe('normalizeDoc', ->
    docTest = new Scribe.Test.HtmlTest((container) ->
      Scribe.Normalizer.normalizeDoc(container)
    )

    docTest.run('empty string', 
      [''], 
      ['<div><br></div>']
    )

    docTest.run('lone break', 
      ['<br>'], 
      ['<div><br></div>']
    )

    docTest.run('correct break', 
      ['<div><br></div>'], 
      ['<div><br></div>']
    )

    docTest.run('handle nonstandard block tags', [
      '<h1>
        <dl><dt>One</dt></dl>
        <pre>Two</pre>
        <p><span>Three</span></p>
      </h1>'
    ], [
      '<div><span>One</span></div>'
      '<div><span>Two</span></div>'
      '<div><span>Three</span></div>'
    ])

    docTest.run('handle nonstandard break tags', [
      '<div><b>One<br><hr>Two</b></div>'
    ], [
      '<div><b>One</b></div>',
      '<div><br></div>',
      '<div><b>Two</b></div>',
    ])
  )
)

