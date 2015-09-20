@Navbar = React.createClass
  displayName: 'Navbar'

  propTypes:
    paths: React.PropTypes.object
    current_user: React.PropTypes.object
    recent: React.PropTypes.string
    message: React.PropTypes.number

  componentDidMount: ->

  render: ->
    <div className="uk-container uk-container-center">
      <a href={@props.paths.root} className="uk-navbar-brand">
        <span className="brand bold">☆12参考表</span>
      </a>
      <ul className="uk-navbar-nav uk-hidden-small">
        <li>
          <a href={@props.paths.users}>
            <i className="fa fa-refresh"></i>
            &nbsp;最近更新したユーザ
          </a>
        </li>
        <MyPage current_user={@props.current_user} paths={@props.paths} recent={@props.recent} />
        <Rival paths={@props.paths} current_user={@props.current_user} />
        <Irt paths={@props.paths} />
        <Conntact paths={@props.paths} />
        <Admin paths={@props.paths} current_user={@props.current_user} />
        <Message current_user={@props.current_user} message={@props.message} />
      </ul>
      <div className="uk-navbar-flip uk-hidden-small">
        <User paths={@props.paths} current_user={@props.current_user} />
      </div>
      <div className="uk-navbar-flip uk-visible-small">
        <a className="uk-navbar-toggle" href="#navbar-offcanvas" data-uk-offcanvas=""></a>
      </div>
    </div>
